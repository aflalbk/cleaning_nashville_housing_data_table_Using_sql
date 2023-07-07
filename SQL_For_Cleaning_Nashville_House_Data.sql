-- Cleaning Data Table Using SQL
SELECT *
FROM PortfolioProject..NashvilleHousingData

-- Populate the Property Address Data
SELECT *
FROM PortfolioProject..NashvilleHousingData
--where PropertyAddress is Null
ORDER BY ParcelID

--From this we find that the conection between proprerty Address and Parcel ID.  
-- we are going to eliminate the null values from Property Address column by using JOIN 
SELECT A.ParcelID
	,A.PropertyAddress
	,B.ParcelID
	,B.PropertyAddress
	,ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousingData AS A
JOIN PortfolioProject..NashvilleHousingData AS B ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL
-- by doing this we copy and pasted the all values have same parcel ID in a NEW column

-- Here raplacing the new column with old column where not have values Property Address. 
UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousingData AS A
JOIN PortfolioProject..NashvilleHousingData AS B ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL

----------------------------------------------------------------------------------------------------------------------
-- Breaking the Property Address into individual column like address and city
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousingData

-- Split a string using a comma and put the resulting values into different columns
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
	,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject..NashvilleHousingData

ALTER TABLE PortfolioProject..NashvilleHousingData ADD AddressOfProperty VARCHAR(255)

UPDATE PortfolioProject..NashvilleHousingData
SET AddressOfProperty = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE PortfolioProject..NashvilleHousingData ADD CityOfProperty VARCHAR(255)

UPDATE PortfolioProject..NashvilleHousingData
SET CityOfProperty = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

------------------------------------------------------------------------------------------------------------------------
-- Breaking the Owner Address into individual column like address, city and State
SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousingData

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousingData

ALTER TABLE PortfolioProject..NashvilleHousingData ADD Owner_Address VARCHAR(255)

UPDATE PortfolioProject..NashvilleHousingData
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..NashvilleHousingData ADD Owner_Citty VARCHAR(255)

UPDATE PortfolioProject..NashvilleHousingData
SET Owner_Citty = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..NashvilleHousingData ADD Owner_State VARCHAR(255)

UPDATE PortfolioProject..NashvilleHousingData
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------------
-- Lets Replace 0 and 1 with "NO" and "YES" respectively in the Sold As Vacant Column
SELECT DISTINCT (SoldAsVacant)
FROM PortfolioProject..NashvilleHousingData

--SELECT  SoldAsVacant
--		,CASE 
--			WHEN SoldAsVacant = 0 THEN 'NO'
--			WHEN SoldAsVacant = 1 THEN 'YES'
--			ELSE SoldAsVacant
--			END
--FROM PortfolioProject..NashvilleHousingData
-- This code didn't work becouse of SoldAsVacant column is bit type and yes or no is a varchar value

-- So plan to Creat a new Column in varchar type. 
SELECT SoldAsVacant
	,CASE 
		WHEN SoldAsVacant = 0
			THEN 'NO'
		WHEN SoldAsVacant = 1
			THEN 'YES'
		END AS SoldAsVacantModified
FROM PortfolioProject..NashvilleHousingData

ALTER TABLE PortfolioProject..NashvilleHousingData ADD SoldAsVacantModified VARCHAR(255)

UPDATE PortfolioProject..NashvilleHousingData
SET SoldAsVacantModified = CASE 
		WHEN SoldAsVacant = 0
			THEN 'NO'
		WHEN SoldAsVacant = 1
			THEN 'YES'
		END
FROM PortfolioProject..NashvilleHousingData
	
---------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates
	
-- It's not work becouse we can't use created column in "where"
--SELECT *, 
--		ROW_NUMBER() OVER(
--			PARTITION BY ParcelID
--						,PropertyAddress
--						,SalePrice
--						,OwnerName
--						,LegalReference
--						ORDER BY UniqueID
--						) Row_name
--FROM PortfolioProject..NashvilleHousingData
--WHERE Row_name > 1
--ORDER BY UniqueID

-- So we made a CET called RowNumCET
	WITH RowNumCTE AS (
		SELECT *
			,ROW_NUMBER() OVER (
				PARTITION BY ParcelID
				,PropertyAddress
				,SalePrice
				,OwnerName
				,LegalReference ORDER BY UniqueID
				) Row_name
		FROM PortfolioProject..NashvilleHousingData
		)

SELECT *
FROM RowNumCTE
WHERE Row_name > 1
-- So now delete all of them. 
WITH RowNumCTE AS (
		SELECT *
			,ROW_NUMBER() OVER (
				PARTITION BY ParcelID
				,PropertyAddress
				,SalePrice
				,OwnerName
				,LegalReference ORDER BY UniqueID
				) Row_name
		FROM PortfolioProject..NashvilleHousingData
		)

DELETE
FROM RowNumCTE
WHERE Row_name > 1

--------------------------------------------------------------------------------------------------------------------------------
-- Delete the unused Columns in the Table
ALTER TABLE PortfolioProject..NashvilleHousingData

DROP COLUMN PropertyAddress
	,LegalReference
	,OwnerAddress
	,TaxDistrict
	,SoldAsVacant