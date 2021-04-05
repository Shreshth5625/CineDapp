pragma solidity ^0.5.1;

import "./TokenFactory.sol";
import "./SafeMath.sol";

contract MovieContract {
  using SafeMath for uint256;

  address payable public owner;
  address public tokenAddress;
  string public movieName;
  string public summary;
  string public tokenName;
  uint256 public totalSupply;
  uint256 public totalTokenSold;
  uint256 public investorCount;
  uint256 public requestCount;
  uint256 public totalInvestment;
  uint256 public totalProfit;
  string[] public updates;

 uint256 public numOfTokens=100; 
 uint256 public rate;

  enum State { PRE_PRODUCTION, PRODUCTION, RELEASED, OVER } 
  State public currentState = State.PRE_PRODUCTION;
  
TokenFactory public token;


constructor(string memory _movieName, address payable _movieCreator) public{
    owner = _movieCreator;
    movieName = _movieName;
    movie.creationDate = now;
  }
// Stucts
  struct movieDetails{
    string name;
    string details;
    uint256 creationDate;
    uint256 deadline;
  }

  struct investorDetails{
    string name;
    string contactDetails;
    address payable investorAddress;
    uint256 tokensBought;
  }

  struct WithdrawRequest{
  	 uint256 amountOfEth;
     uint256 numberOfVoters;
  	 string description;
  	 string receiverDesignation;
     bool completed;
     address payable recipient;
    
    mapping(address=>bool) voters;
  }

   movieDetails public movie;

//Mappings
  mapping (address => bool) public profitAdded;
  mapping (address => investorDetails)public investors;
  mapping (address => uint256 ) public investedAmount;
  mapping (uint256 => WithdrawRequest) public requests;
  

  modifier  onlyOwner() { 
    require(msg.sender == owner, "Caller is not the owner"); 
    _; 
  }
  
//Events
  event TokenSold(address buyer,uint256 amount);
  event etherWithdrawn(address rec,string designation,uint256 amount);
  event MovieState(State _currentState, uint _currentRate);
  event etherReleased(uint256 _amount, string _reason); //only owner releases funds small expenses



  function addMovie(string memory _details, uint256 _timeInDays, uint expectedBudget) public onlyOwner{
    movie.name = movieName;
    movie.details = _details;
    movie.deadline = now + _timeInDays * 1 days;
    rate = (expectedBudget).div(numOfTokens) * 10 ** 18;
  }

  function createMovieToken(string memory _symbol, string memory _name) public onlyOwner{
      token = new TokenFactory(_symbol, _name, numOfTokens);
      tokenAddress = address(token);
      tokenName = _name;
      totalSupply = numOfTokens;
  }

  function updateState(State _state) public onlyOwner{
    currentState = _state;
    emit MovieState(currentState, rate);
  }

  function projectUpdate(string memory _update) public onlyOwner {
    updates.push(_update);
  }

  function reportProfit(uint tokensEarnedFromTicketsSold) public payable onlyOwner {// random mumber
    require(currentState == State.RELEASED);
    uint profitCalculated = tokensEarnedFromTicketsSold.sub(rate.mul(totalTokenSold));
    require(profitCalculated > 0);
    totalProfit += profitCalculated;
    
    rate = totalProfit.div(totalTokenSold);
    currentState=State.OVER;
    emit MovieState(currentState, rate);   
  }

  function buyMovieTokens(string memory _name, string memory _contact) public payable{
    require (msg.value > 0);
    token = TokenFactory(tokenAddress);
    uint256 _numberOfTokens = msg.value.div(rate);
    address payable _to = msg.sender;
    
    require(token.balanceOf(address(owner)) >= _numberOfTokens, "Token Quantity Exceeded");//redundant add diff
    investorCount++;
    investors[msg.sender] = investorDetails(_name, _contact,_to,_numberOfTokens.div(1000000000000000000));
    investedAmount[_to] = msg.value;
    token.transfer(_to,_numberOfTokens);
    totalTokenSold += _numberOfTokens;
    totalInvestment += msg.value;
    emit TokenSold(_to,_numberOfTokens);
  }


  function getBalance() public view returns(uint256){
      return address(this).balance;
  }

  function latestUpdate() public view returns(string memory) {
    return updates[updates.length-1];
  }
  
    
   
}
