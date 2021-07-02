
-- Cleaning Data using SQL Queries in order to make data easier to read

-- Standardized Date format converting date format from 'datetime' to 'date'

Alter Table PortfolioProject..NashvilleHousing
Add SaleDateConverted date;

Update PortfolioProject..NashvilleHousing
Set SaleDateConverted = Convert(date, SaleDate)

Select SaleDate, SaleDateConverted, Convert(date, SaleDate)
From PortfolioProject..NashvilleHousing

-- Populate property address data by replacing record that is null to coresponding address that have same ParcelID joining table on it self

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) as AddressReplacement
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Property Address into individual columns (Address, City) by adding two columns and populating them with coresponding parts of Property Address

Alter Table PortfolioProject..NashvilleHousing
Add PropertyDivAddress nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set PropertyDivAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table PortfolioProject..NashvilleHousing
Add PropertyDivCity nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set PropertyDivCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select UniqueID, PropertyAddress, PropertyDivAddress, PropertyDivCity
From PortfolioProject..NashvilleHousing
Order by UniqueID

-- Breaking out Owner Address into individual colums (Address, City) by adding three columns and populating them with coresponding parts of Owner Address

Alter Table PortfolioProject..NashvilleHousing
Add OwnerDivAddress nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerDivAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

Alter Table PortfolioProject..NashvilleHousing
Add OwnerDivCity nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerDivCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

Alter Table PortfolioProject..NashvilleHousing
Add OwnerDivState nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerDivState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

Select UniqueID, OwnerAddress, OwnerDivAddress, OwnerDivCity, OwnerDivState
From PortfolioProject..NashvilleHousing
Order by UniqueID

-- Change Y and N to Yes and No in "Sold as vacant" column to standardise format of data presented

Select Distinct(SoldAsVacant), Count(SoldAsVacant) as NumberOfRecord
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Update PortfolioProject..NashvilleHousing
Set SoldAsVacant = 
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End

-- Remove duplicates of records to clean up data


With RowNumCTE as(
Select *,
Row_Number() Over (
Partition by ParcelID, PropertyDivAddress, PropertyDivCity, SaleDateConverted, SalePrice, LegalReference
Order by UniqueID
) row_num
From PortfolioProject..NashvilleHousing
)
Select* --Change 'Select*' with 'DELETE' if there are duplicate records, change back to 'Select*' to check that all duplicates are removed
From RowNumCTE	
Where row_num > 1

-- Delete unused columns to clean up data that are no longer needed

Alter Table PortfolioProject..NashvilleHousing
Drop Column PropertyAddress, OwnerAddress, SaleDate

Select *
From PortfolioProject..NashvilleHousing