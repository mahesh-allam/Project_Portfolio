--Pull all Data
Select * from Housing

--------------------------------------------------------------------------------------------------------------

--Standardize Date Format

Select SaleDateConverted as SaleDate
from Housing

Update Housing
Set SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE housing
Add SaleDateConverted Date;

Update Housing
Set SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------------------------
--Populate Property Address data

select *  
from Housing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.PropertyAddress, b.ParcelID, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Housing a
JOIN Housing b
	on a.ParcelID= b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Housing a
JOIN Housing b
	on a.ParcelID= b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------
--Breaking out Address into individual Columns(Address,city,state)

select PropertyAddress 
from Housing
----where PropertyAddress is null
--order by ParcelID

SELECT Housing.PropertyAddress,
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address, CHARINDEX(',',PropertyAddress),
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
From housing

ALTER TABLE housing
Add PropertySplitAddress  Nvarchar(255);

Update Housing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE housing
Add PropertySplitCity Nvarchar(255);

Update Housing
Set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select PARSENAME(Replace(OwnerAddress, ',', '.'),3),
PARSENAME(Replace(OwnerAddress, ',', '.'),2),
PARSENAME(Replace(OwnerAddress, ',', '.'),1)
from Housing

ALTER TABLE housing
Add OwnerSplitAddress  Nvarchar(255);

Update Housing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'),3)

ALTER TABLE housing
Add OwnerSplitCity Nvarchar(255);

Update Housing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'),2)


ALTER TABLE housing
Add OwnerSplitState Nvarchar(255);

Update Housing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'),1)


Select * from Housing

--------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant) as Tol
from Housing
group by SoldAsVacant
order by Tol asc;

Select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from Housing

update Housing
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

--------------------------------------------------------------------------------------------------------
--Remove duplicates

WITH RowNumCTE As(
select *,
	row_number() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					)row_num
from Housing
)

select * from RowNumCTE
where row_num>1
order by PropertyAddress

-------------------------------------------------------------------------------------------------------------------

--Delete unused Columns

Select *
from Housing

Alter table housing
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Alter table housing
Drop column SaleDate






























































