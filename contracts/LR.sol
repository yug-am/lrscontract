// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

contract LR {
    address public contractDepartment;
    enum LegalEntityCategory {
        Company,
        Business,
        HUF,
        Firm,
        Body
    }
    enum PlotCategory {
        Residential,
        Commercial,
        Agricultural,
        Institutional,
        Industrial
    }
    enum TransferCategory {
        NotApplicable,
        Sale,
        LoanSale,
        InheritDivorce,
        CourtOrder,
        ErrorCorrection,
        GensisEntry,
        GenesisLoanEntry,
        SaleRetained
    }
    enum OwnerType {
        LegalEntity,
        Citizen
    }
  
    struct RegistryOffice {
        address roAccount; //key in mapping
        uint16 roId; //secondary mapping regOfficeIdAccMapping
        string state;
        uint16 districtId;
        uint24 pincode;
    }
    struct Bank {
        address bankAccount; //key in mapping
        string ifsc; //secondary mapping  bankIdAccMapping
        string bankName;
        string state;
        uint16 districtId;
        string branch;
    }
  
    struct Plot {
        bytes32 plotHash; //key in plotMapping
        string state; //part of hash used for key
        uint16 districtId; //part of hash used for key
        string surveyNo; //part of hash used for key
        uint16 divisionNo; //part of hash used for key
        uint32 plotNo; //part of hash used for key
        uint24 pincode;
        PlotCategory category;
        uint32 plotArea;
    }
    struct Khatauni {
        bytes32 khatauniHash; //key in plotMapping
        uint256 khatauniId; //part of hash used for key
        bytes32 plotHash; //part of hash used for key
        bytes32 prevKhatauniHash; //part of hash used for key
        bytes32[] nextKhatauniHashList;
        TransferCategory transferType;
        TransferCategory nextTransferType;
        uint64[] ownerList;
        OwnerType[] ownerTypeList;
        uint32[] ownerAreaList;
        string stampDutyReference;
        string caseReference;
        uint16 courtId;
        string loanReference;
        address bank;
        uint32 amount;
        bool isDisputed;
        bool isUnderLoan;
    }
  
    mapping(address => RegistryOffice) regOfficeMapping;
    mapping(uint16 => address) regOfficeIdAccMapping;
    mapping(address => Bank) bankMapping;
    mapping(string => address) bankIdAccMapping;
    mapping(bytes32 => Plot) plotMapping;
    mapping(bytes32 => Khatauni) khatauniMapping;

    constructor() {
        contractDepartment = msg.sender;
    }
function viewKhatauni(bytes32 kHash) external view returns(uint256 kid, bool dsp, bool loan, bytes32[] memory nKHash, uint64[] memory ownerList) {
    require(khatauniMapping[kHash].khatauniHash==kHash,"k# doesn't exists");
    kid = khatauniMapping[kHash].khatauniId;
    dsp = khatauniMapping[kHash].isDisputed;
    loan = khatauniMapping[kHash].isUnderLoan;
    nKHash = khatauniMapping[kHash].nextKhatauniHashList;
	ownerList=khatauniMapping[kHash].ownerList;
	

}
    event accAdded(address indexed acc);
    event plotAdded(bytes32 indexed hash);
    event kthEntry(bytes32 indexed hash);
    event kthTxn(bytes32 indexed hash);
    error createError(string what, address a, bytes32 b );
    error khatauniError(string what,bytes32 b );
    
    function createRegistryOffice(
        address _roAccount,
        uint16 _roId,
        string memory _state,
        uint16 _districtId,
        uint24 _pincode
    ) external {
              require(msg.sender == contractDepartment, "Only dept access");
        require(
            regOfficeMapping[_roAccount].roAccount == address(0),
            "RO acc exists"
        );
        require(regOfficeIdAccMapping[_roId] == address(0), "RO ID exists");
      
        regOfficeMapping[_roAccount] = RegistryOffice({
            roAccount: _roAccount,
            roId: _roId,
            state: _state,
            districtId: _districtId,
            pincode: _pincode
        });
        regOfficeIdAccMapping[_roId] = _roAccount;
        emit accAdded(_roAccount);
    }

    function createBank(
        address _bankAccount,
        string memory _ifsc,
        string memory _bankName,
        string memory _state,
        uint16 _districtId,
        string memory _branch
    ) external {
              require(msg.sender == contractDepartment, "Only dept");
        require(
            bankMapping[_bankAccount].bankAccount == address(0),
            "Bank acc. exists"
        );
        require(bankIdAccMapping[_ifsc] == address(0), "IFSC exists");
        bankMapping[_bankAccount] = Bank({
            bankAccount: _bankAccount,
            ifsc: _ifsc,
            bankName: _bankName,
            state: _state,
            districtId: _districtId,
            branch: _branch
        });

        bankIdAccMapping[_ifsc] = _bankAccount;
        emit accAdded(_bankAccount);
    }

 
    function createPlot(
        string memory _state,
        uint16 _districtId,
        string memory _surveyNo,
        uint16 _divisionNo,
        uint32 _plotNo,
        uint24 _pincode,
        PlotCategory _category,
        uint32 _plotArea
    ) external returns (bytes32 pHash)  {
         
     require(
            regOfficeMapping[msg.sender].roAccount == msg.sender,
            "LRO acc only"
        );
        // pass uint, 0: Residential, 1: Commercial, 2: Agricultural, 3: Institutional, 4: Industrial
        bytes32 _plotHash = keccak256(
            abi.encodePacked(
                _state,
                _districtId,
                _surveyNo,
                _divisionNo,
                _plotNo
            )
        );
   require(
            plotMapping[_plotHash].plotHash == bytes32(0),
            "Plot hash exists"
        );

        plotMapping[_plotHash] = Plot({
            plotHash: _plotHash,
            state: _state,
            districtId: _districtId,
            surveyNo: _surveyNo,
            divisionNo: _divisionNo,
            plotNo: _plotNo,
            pincode: _pincode,
            category: _category,
            plotArea: _plotArea
        });
        pHash = _plotHash;
        emit plotAdded(_plotHash);
    }

    function KhatauniGenesisEntry(
        uint256 _khatauniId,
        bytes32 _plotHash,
        uint64[] memory _ownerList,
        OwnerType[] memory _ownerTypeList,
        uint32[] memory _ownerAreaList
    ) external returns (bytes32 rKHash)  {
        
     require(
            regOfficeMapping[msg.sender].roAccount == msg.sender,
            "LRO acc only"
        );
        bytes32 _khatauniHash = keccak256(
            abi.encodePacked(_khatauniId, _plotHash)
        );
      require(
            khatauniMapping[_khatauniHash].khatauniHash != _khatauniHash,
            "Khatauni Hash exists!"
        );
        require(
            plotMapping[_plotHash].plotHash != bytes32(0),
            "Plot does not exist!"
        );


        khatauniMapping[_khatauniHash] = Khatauni({
            khatauniHash: _khatauniHash,
            khatauniId: _khatauniId,
            plotHash: _plotHash,
            prevKhatauniHash: 0,
            nextKhatauniHashList: new bytes32[](0),
            transferType: TransferCategory.GensisEntry,
            nextTransferType: TransferCategory.NotApplicable,
            ownerList: _ownerList,
            ownerTypeList: _ownerTypeList,
            ownerAreaList: _ownerAreaList,
            stampDutyReference: "",
            courtId: 0,
            caseReference: "",
            loanReference: "",
            bank: address(0),
            amount: 0,
            isDisputed: false,
            isUnderLoan: false
        });
        rKHash = _khatauniHash;
         emit kthEntry(_khatauniHash);
    }

    function KhatauniLoanGenesisEntry(
        uint256 _khatauniId,
        bytes32 _plotHash,
        uint64[] memory _ownerList,
        OwnerType[] memory _ownerTypeList,
        uint32[] memory _ownerAreaList,
        address _bank,
        string memory _loanRef,
        uint32 _amount
    ) external returns (bytes32 rKHash) {
    require(
            regOfficeMapping[msg.sender].roAccount == msg.sender,
            "LRO acc only"
        );
        bytes32 _khatauniHash = keccak256(
            abi.encodePacked(_khatauniId, _plotHash)
        );
     require(
            khatauniMapping[_khatauniHash].khatauniHash != _khatauniHash,
            "Khatauni Hash already exists!"
        );
        require(
            plotMapping[_plotHash].plotHash != bytes32(0),
            "Plot does not exist!"
        );
        require(
            bankMapping[_bank].bankAccount != address(0),
            "Bank acc. exists"
        );

        khatauniMapping[_khatauniHash] = Khatauni({
            khatauniHash: _khatauniHash,
            khatauniId: _khatauniId,
            plotHash: _plotHash,
            prevKhatauniHash: 0,
            nextKhatauniHashList: new bytes32[](0),
            transferType: TransferCategory.GenesisLoanEntry,
            nextTransferType: TransferCategory.NotApplicable,
            ownerList: _ownerList,
            ownerTypeList: _ownerTypeList,
            ownerAreaList: _ownerAreaList,
            stampDutyReference: "",
            courtId: 0,
            caseReference: "",
            loanReference: _loanRef,
            bank: _bank,
            amount: _amount,
            isDisputed: false,
            isUnderLoan: true
        });
      
        rKHash = _khatauniHash;
        emit kthEntry(_khatauniHash);
    }

    function sourceKhatauniIssue(bytes32 khatauniHash)
        internal
        view
        returns (bool)
    {
        Khatauni storage khatauni = khatauniMapping[khatauniHash];
        return
            khatauni.isUnderLoan ||
            khatauni.isDisputed ||
            khatauni.nextKhatauniHashList.length > 0;
    }

    function KhatauniSale(
        bytes32 _sourceKhatauniHash,
        uint32[] memory _areaSellList,
        uint64[] memory _buyerList,
        OwnerType[] memory _buyerTypeList,
        uint32[] memory _buyerAreaList,
        string memory _stampDutyReference,
        uint32 _amount,
        uint256[] memory _newKhatauniIdList,
        bool _jointOwnership,
        address _bank,
        string memory _loanRef
    ) external  {
         require(
            regOfficeMapping[msg.sender].roAccount == msg.sender,
            "LRO acc only"
        );
        require(!sourceKhatauniIssue(_sourceKhatauniHash),"not sellable");
        Khatauni storage sourceKhatauni = khatauniMapping[_sourceKhatauniHash];
require(
            _areaSellList.length == sourceKhatauni.ownerList.length,
            "areaSell, owner arr size mismatch"
        );
        // selling <=owned check
        for (uint8 i = 0; i < _areaSellList.length; i++) {
             if(_areaSellList[i] > sourceKhatauni.ownerAreaList[i]){
            require(
                _areaSellList[i] <= sourceKhatauni.ownerAreaList[i],
                "Selling area > owner's area"
            );
        }

        }

        sourceKhatauni.nextTransferType = TransferCategory.Sale;
        if (_jointOwnership) {
            bytes32 currKhatauniHash = keccak256(
                abi.encodePacked(_newKhatauniIdList[0], sourceKhatauni.plotHash)
            );
            khatauniMapping[currKhatauniHash] = Khatauni({
                khatauniHash: currKhatauniHash,
                khatauniId: _newKhatauniIdList[0],
                plotHash: sourceKhatauni.plotHash,
                prevKhatauniHash: _sourceKhatauniHash,
                nextKhatauniHashList: new bytes32[](0),
                transferType: TransferCategory.Sale,
                nextTransferType: TransferCategory.NotApplicable,
                ownerList: _buyerList,
                ownerTypeList: _buyerTypeList,
                ownerAreaList: _buyerAreaList,
                stampDutyReference: _stampDutyReference,
                courtId: 0,
                caseReference: "",
                loanReference: "",
                bank: address(0),
                amount: _amount,
                isDisputed: false,
                isUnderLoan: false
            });
            if (bytes(_loanRef).length != 0) {
                khatauniMapping[currKhatauniHash].isUnderLoan = true;
                khatauniMapping[currKhatauniHash].bank = _bank;
                khatauniMapping[currKhatauniHash].loanReference = _loanRef;
            }
            sourceKhatauni.nextKhatauniHashList.push(currKhatauniHash);
        } else {
            for (uint8 i = 0; i < _buyerList.length; i++) {
                bytes32 currKhatauniHash = keccak256(
                    abi.encodePacked(
                        _newKhatauniIdList[i],
                        sourceKhatauni.plotHash
                    )
                );
                khatauniMapping[currKhatauniHash] = Khatauni({
                    khatauniHash: currKhatauniHash,
                    khatauniId: _newKhatauniIdList[i],
                    plotHash: sourceKhatauni.plotHash,
                    prevKhatauniHash: _sourceKhatauniHash,
                    nextKhatauniHashList: new bytes32[](0),
                    transferType: TransferCategory.Sale,
                    nextTransferType: TransferCategory.NotApplicable,
                    ownerList: new uint64[](0),
                    ownerTypeList: new OwnerType[](0),
                    ownerAreaList: new uint32[](0),
                    stampDutyReference: _stampDutyReference,
                    courtId: 0,
                    caseReference: "",
                    loanReference: "",
                    bank: address(0),
                    amount: _amount,
                    isDisputed: false,
                    isUnderLoan: false
                });
                if (bytes(_loanRef).length != 0) {
                    khatauniMapping[currKhatauniHash].isUnderLoan = true;
                    khatauniMapping[currKhatauniHash].bank = _bank;
                    khatauniMapping[currKhatauniHash].loanReference = _loanRef;
                }
                sourceKhatauni.nextKhatauniHashList.push(currKhatauniHash);
                khatauniMapping[currKhatauniHash].ownerList.push(_buyerList[i]);
                khatauniMapping[currKhatauniHash].ownerTypeList.push(
                    _buyerTypeList[i]
                );
                khatauniMapping[currKhatauniHash].ownerAreaList.push(
                    _buyerAreaList[i]
                );
            }
        }

        for (uint8 i = 0; i < sourceKhatauni.ownerList.length; i++) {
            if (sourceKhatauni.ownerAreaList[i] - _areaSellList[i] > 0) {
                bytes32 currKhatauniHash = keccak256(
                    abi.encodePacked(
                        _newKhatauniIdList[i + _buyerList.length],
                        sourceKhatauni.plotHash
                    )
                );

                khatauniMapping[currKhatauniHash] = Khatauni({
                    khatauniHash: currKhatauniHash,
                    khatauniId: _newKhatauniIdList[i + _buyerList.length],
                    plotHash: sourceKhatauni.plotHash,
                    prevKhatauniHash: _sourceKhatauniHash,
                    nextKhatauniHashList: new bytes32[](0),
                    transferType: TransferCategory.SaleRetained,
                    nextTransferType: TransferCategory.NotApplicable,
                    ownerList: new uint64[](0),
                    ownerTypeList: new OwnerType[](0),
                    ownerAreaList: new uint32[](0),
                    stampDutyReference: "",
                    courtId: 0,
                    caseReference: "",
                    loanReference: "",
                    bank: address(0),
                    amount: 0,
                    isDisputed: false,
                    isUnderLoan: false
                });

                khatauniMapping[currKhatauniHash].ownerList.push(
                    sourceKhatauni.ownerList[i]
                );
                khatauniMapping[currKhatauniHash].ownerTypeList.push(
                    sourceKhatauni.ownerTypeList[i]
                );
                khatauniMapping[currKhatauniHash].ownerAreaList.push(
                    (sourceKhatauni.ownerAreaList[i] - _areaSellList[i])
                );

                sourceKhatauni.nextKhatauniHashList.push(currKhatauniHash);
            }
        }
        emit kthTxn(_sourceKhatauniHash);
    }

    function CourtDispute(bytes32 _kHash, uint16 _court, string memory _caseRef) external {
             require(
            regOfficeMapping[msg.sender].roAccount == msg.sender,
            "LRO acc only"
        );
        require(khatauniMapping[_kHash].khatauniHash!=bytes32(0), "K# doesnot exists");
        if(_court!=0){
            khatauniMapping[_kHash].isDisputed=true;
            khatauniMapping[_kHash].courtId=_court;
            khatauniMapping[_kHash].caseReference=_caseRef;
        }
        else{
             khatauniMapping[_kHash].isDisputed=false;
            khatauniMapping[_kHash].courtId=0;
            khatauniMapping[_kHash].caseReference="";
        }
         emit kthTxn(_kHash);
    }
    function loanCompletion(bytes32 _kHash) external{
       
         require(
            khatauniMapping[_kHash].bank == msg.sender,
            "only bank acc"
        );
           require(khatauniMapping[_kHash].khatauniHash!=bytes32(0), "K# doesnot exists");
        khatauniMapping[_kHash].isUnderLoan=false;
        khatauniMapping[_kHash].bank=address(0);
        khatauniMapping[_kHash].loanReference="";
        emit kthTxn(_kHash);
    }
    function courtOrder(bytes32 _kHash,
        uint64[] memory _buyerList,
        OwnerType[] memory _buyerTypeList,
        uint32[] memory _buyerAreaList,
        string memory _stampDutyReference,
        uint32 _amount,
        uint256[] memory _newKhatauniIdList
        )external{
         require(
            regOfficeMapping[msg.sender].roAccount == msg.sender,
            "LRO acc only"
        );
        require(
            khatauniMapping[_kHash].isDisputed,
            "not disputed"
        );
          for (uint8 i = 0; i < _buyerList.length; i++) {
                bytes32 currKhatauniHash = keccak256(
                    abi.encodePacked(
                        _newKhatauniIdList[i],
                        khatauniMapping[_kHash].plotHash
                    )
                );
                khatauniMapping[currKhatauniHash] = Khatauni({
                    khatauniHash: currKhatauniHash,
                    khatauniId: _newKhatauniIdList[i],
                    plotHash: khatauniMapping[_kHash].plotHash,
                    prevKhatauniHash: _kHash,
                    nextKhatauniHashList: new bytes32[](0),
                    transferType: TransferCategory.CourtOrder,
                    nextTransferType: TransferCategory.NotApplicable,
                    ownerList: new uint64[](0),
                    ownerTypeList: new OwnerType[](0),
                    ownerAreaList: new uint32[](0),
                    stampDutyReference: _stampDutyReference,
                    courtId: 0,
                    caseReference: "",
                    loanReference: "",
                    bank: address(0),
                    amount: _amount,
                    isDisputed: false,
                    isUnderLoan: false
                });
            
                khatauniMapping[_kHash].nextKhatauniHashList.push(currKhatauniHash);
                khatauniMapping[currKhatauniHash].ownerList.push(_buyerList[i]);
                khatauniMapping[currKhatauniHash].ownerTypeList.push(
                    _buyerTypeList[i]
                );
                khatauniMapping[currKhatauniHash].ownerAreaList.push(
                    _buyerAreaList[i]
                );
            }


    emit kthTxn(_kHash);
    }

}

