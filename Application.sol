ragma solidity ^0.4.7;

contract Application {

    struct Approver {
        string role;
        string name;
    }
    
    struct Specification {
        uint cpu;
        uint ram;
        uint capacity;
        uint nic;
    }
    
    enum Status {Submitted, Valid, Running, Decommissioned, Deployed, Approved, Rejected}
    enum TShirtSize { Small, Medium, Large}

    address requestor;
    mapping (uint => string) requiredRoles;
    mapping (uint => string) approvedRoles;
    mapping (uint => Approver) approvers;
    uint numApprovers;
    uint numReqRoles;
    uint numApprovedRoles;
    Specification applicationSpecs;
    string applicationName;
    Status status;
    address nullAddress;
    int approveRC;
    
    event ApplicationCreated(address indexed requestor, uint indexed numReqApprovers);
    event WrongApplicationSize(uint indexed _size);
    event Killed(address indexed owner);
    event AddingRequiredRole(string indexed _role);
    event RequiredRoleAdded(uint indexed numReqApprover, string indexed _role);
    event CheckingRole(string indexed _role);
    event RoleAlreadyExists(string indexed _role);
    event AddingRole(string indexed _role);
    event RoleAdded(uint indexed numApprovedRole, string indexed _role);
    event AddingApprover(string indexed _name, string indexed _role);
    event ApproverAdded(uint indexed numApprovers, string indexed _name, string indexed _role);
    event ApplicationApproved();
    
    function Application(address _requestor, uint _size, string _name) {
        nullAddress = 0x0000000000000000000000000000000000000000;
        requestor = _requestor;
        numApprovers = 0;
        numApprovedRoles = 0;
        applicationName = _name;
        numReqRoles = 0;
        status = Status.Submitted;
        if(_size == 1) { applicationSpecs.cpu = 1; applicationSpecs.ram = 4; applicationSpecs.capacity = 1024; applicationSpecs.nic = 1; }
        else if (_size == 2) { applicationSpecs.cpu = 2; applicationSpecs.ram = 8; applicationSpecs.capacity = 2048; applicationSpecs.nic = 2; }
        else if(_size == 3) { applicationSpecs.cpu = 4; applicationSpecs.ram = 16; applicationSpecs.capacity = 4096; applicationSpecs.nic = 4; }
        else {
                WrongApplicationSize(_size);
            }
        ApplicationCreated(requestor, numReqRoles);
    }
    
    function addRequiredRole(string _role) {
        AddingRequiredRole(_role);
        requiredRoles[numReqRoles] = _role;
        numReqRoles += 1;
        RequiredRoleAdded(numReqRoles, requiredRoles[numReqRoles]);
    }
    
    //might need to test this as requiredApprovers is a mapping and the function is returning a string
    function getRequiredRole(uint index) constant returns(string) {
        return(requiredRoles[index]);
    }
    
    function getApprover(uint index) constant returns(string, string) {
        return(approvers[index].name, approvers[index].role);
    }
    
    function getApprovalsStatus() constant returns(uint, uint, uint) {
        return(uint(status), numReqRoles, numApprovedRoles);
    }
    
    //Should work!!! To be tested!!!
    function approve(string _name, string _role) {
        uint i;
        uint roleRequired;
        uint roleAlreadyApproved;
        
        roleAlreadyApproved = 0;
        AddingApprover(_name, _role);
        approvers[numApprovers].name = _name;
        approvers[numApprovers].role = _role;
        numApprovers += 1;
        ApproverAdded(numApprovers, approvers[numApprovers - 1].name, approvers[numApprovers - 1].role);
        
        CheckingRole(_role);
        for(i = 0; i < numApprovedRoles; i++) {
            if(sha3(approvedRoles[i]) == sha3(_role)) { 
                roleAlreadyApproved = 1; 
                RoleAlreadyExists(approvedRoles[i]);
            }
        }
        
        for(i = 0; i < numReqRoles; i++) {
            if(sha3(_role) == sha3(requiredRoles[i])) {
                roleRequired = 1;
            }
        }
        
        //If roleAlreadyApproved is 0, then that means nobody from this role has approved the application
        //Which means we need to add it to the list of roles which have approved 
        if(roleAlreadyApproved == 0 && roleRequired == 1) {
            AddingRole(_role);
            approvedRoles[numApprovedRoles] = _role;
            numApprovedRoles += 1;
            RoleAdded(numApprovedRoles, approvedRoles[numApprovedRoles - 1]);
        }
        
        if(numApprovedRoles == numReqRoles) {
            status = Status.Approved;
            ApplicationApproved();
        }
    }    
    
    function getApprovedRole(uint index) constant returns(string) {
        return(approvedRoles[index]);
    }
    
    function getApproveRC() constant returns(int) {
        return(approveRC);
    }
    
    function getRequestor() constant returns(address) {
        return(requestor);
    }
    
    function getNumApprovers() constant returns(uint) {
        return(numApprovers);
    }

    function getApplicationName() constant returns(string) {
        return(applicationName);
    }
    
    function getSpecification() constant returns(uint, uint, uint, uint) {
        return(applicationSpecs.cpu, applicationSpecs.ram, applicationSpecs.capacity, applicationSpecs.nic);
    }
    
    function getStatus() constant returns(uint) {
        return(uint(status));
    }
    
    function changeStatus(uint _status) {
        if(_status == 1) { status = Status.Submitted; return; }
        if(_status == 2) { status = Status.Valid; return; }
        if(_status == 3) { status = Status.Running; return; }
        if(_status == 4) { status = Status.Decommissioned; return; }
        if(_status == 5) { status = Status.Deployed; return; }
        if(_status == 6) { status = Status.Approved; return; }
        if(_status == 7) { status = Status.Rejected; return; }
    }
    
    
    function kill() {
        if (msg.sender == requestor) {
            Killed(requestor);
            suicide(requestor);
        }
    }    
}
