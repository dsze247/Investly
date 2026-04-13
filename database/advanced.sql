--
DELIMITER $$
CREATE TRIGGER update_holding_after_transaction
AFTER INSERT ON AssetTransaction
FOR EACH ROW
BEGIN
    IF NEW.transaction_type = 'Buy' THEN
        -- If holding exists, update it; otherwise insert a new row
        IF EXISTS (
            SELECT 1 FROM PortfolioHolding
            WHERE portfolio_id = NEW.portfolio_id AND asset_id = NEW.asset_id
        ) THEN
            UPDATE PortfolioHolding
            SET average_cost = ((average_cost * total_quantity) + (NEW.price_per_unit * NEW.quantity))
                               / (total_quantity + NEW.quantity),
                total_quantity = total_quantity + NEW.quantity
            WHERE portfolio_id = NEW.portfolio_id AND asset_id = NEW.asset_id;
        ELSE
            INSERT INTO PortfolioHolding (portfolio_id, asset_id, total_quantity, average_cost)
            VALUES (NEW.portfolio_id, NEW.asset_id, NEW.quantity, NEW.price_per_unit);
        END IF;

    ELSEIF NEW.transaction_type = 'Sell' THEN
        UPDATE PortfolioHolding
        SET total_quantity = total_quantity - NEW.quantity
        WHERE portfolio_id = NEW.portfolio_id AND asset_id = NEW.asset_id;

        -- Remove the holding row if quantity reaches zero
        DELETE FROM PortfolioHolding
        WHERE portfolio_id = NEW.portfolio_id
          AND asset_id = NEW.asset_id
          AND total_quantity <= 0;
    END IF;
END$$
DELIMITER ;

-- 
DELIMITER $$
CREATE PROCEDURE record_portfolio_snapshot(
    IN p_portfolio_id INT,
    IN p_recorded_at DATETIME
)
BEGIN
    DECLARE v_total_value DECIMAL(15,3);
    DECLARE v_unrealized_gains DECIMAL(15,3);

    -- Calculate total current value: sum of (quantity * latest close price) for each holding
    SELECT
        SUM(ph_hold.total_quantity * ph_price.close_price),
        SUM((ph_price.close_price - ph_hold.average_cost) * ph_hold.total_quantity)
    INTO
        v_total_value,
        v_unrealized_gains
    FROM PortfolioHolding ph_hold
    INNER JOIN PriceHistory ph_price ON ph_hold.asset_id = ph_price.asset_id
    WHERE ph_hold.portfolio_id = p_portfolio_id
      AND ph_price.recorded_date = (
          SELECT MAX(recorded_date)
          FROM PriceHistory
          WHERE asset_id = ph_hold.asset_id
      );

    -- Insert a new history record with the calculated values
    INSERT INTO PortfolioHistory (
        portfolio_id,
        total_value,
        unrealized_gains,
        daily_return,
        monthly_return,
        recorded_at
    )
    VALUES (
        p_portfolio_id,
        IFNULL(v_total_value, 0),
        IFNULL(v_unrealized_gains, 0),
        0.000, -- daily/monthly return can be updated separately or calculated later
        0.000,
        p_recorded_at
    );
END$$
DELIMITER ;
