INSERT INTO DefaultCPSKUs(SKUID, CPSKUID, CPFor, CPGet, DefaultCP, SalesPointID, [Status], CreatedBy)

select CPS.SKUID, CPS.CPSKUID, CPS.CPFor, CPS.CPGet, CPS.DefaultCP, SP.SalesPointID, 16, -9 from SKUCPs CPS
inner join SalesPoints SP On CPS.SystemID = CPS.SystemID
where CPSKUID IS NOT NULL