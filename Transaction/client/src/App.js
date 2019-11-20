import React, { Component } from "react";
import Room from "./contracts/Room.json";
import getWeb3 from "./utils/getWeb3";
import DatePicker from "react-datepicker";
import "react-datepicker/dist/react-datepicker.css";

import "./App.css";
import { addHours } from "date-fns/esm";

var count=0;
var timetest;

class App extends Component {
  state = { timestamp: 1,
            endTime: addHours(new Date(), 1),
            startTime: new Date(),  
            totalRoom: null, 
            nameRoom: [],
            storageValue: null, 
            timelist: [], 
            list: [], 
            web3: null, 
            accounts: null, 
            contract: null,
            seconds: 0 };

  cron = async() => {
    const { accounts, contract } = this.state;

    for(var i = 0; i < this.state.totalRoom; i++){
      var d = new Date().valueOf();
      var response = await contract.methods.getTime( i ).call();
      timetest = response[0];
      if( d >= response[0] && d <= response[2] && response[3] == 0){
        await contract.methods.startRent( i ).send({ from: accounts[0] });
      }else if(d >= response[2] && response[3] == true){
        await contract.methods.restore( i ).send({ from: accounts[0] });
      }
    }
  }

  handleChangeStart(date) {
    this.setState({
      startTime: date,
      endTime: addHours(date, this.state.timestamp)
    });
  };

  handleChangeTime(date) {
    var temp = document.getElementById("r_timestamp").value;
    this.setState({
      timestamp: temp,
      endTime: addHours(this.state.startTime, temp)
    })
  }

  componentWillUnmount() {
    clearInterval(this.interval);
  }

  componentDidMount = async () => {
    try {
      this.interval = setInterval(() => this.cron(), 30000);
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = Room.networks[networkId];
      const instance = new web3.eth.Contract(
        Room.abi,
        deployedNetwork && deployedNetwork.address,
      );

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ web3, accounts, contract: instance }, this.getIndex);
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };

  register = async() => {
    const { accounts, contract } = this.state;
    const r_name = document.getElementById("r_name").value;
    const r_price = document.getElementById("r_price").value;

    // Stores a given value, 5 by default.
    await contract.methods.register( r_name, r_price ).send({ from: accounts[0] });
  };

  rent = async() => {
    const { accounts, contract } = this.state;
    const rent_id = document.getElementById("rent_id").value;
    const start = this.state.startTime.valueOf();
    const timestamp = this.state.timestamp;
    const end = this.state.endTime.valueOf();

    if(rent_id == -1){
      return alert('Please select room');
    }

    const status = await contract.methods.checkAvailable( rent_id ).call({ from:accounts[0] });

    //check if the room available
    if(status == 0){
      return alert('You cant rent your own room');
    }else if(status == 2){
      return alert('The room is being rented');
    }else{
      const fee = await contract.methods.computeFee( rent_id, timestamp ).call();
      await contract.methods.rental( rent_id, start, timestamp, end ).send({ from: accounts[0], value: fee });
    }
  };

  return = async() => {
    const { accounts, contract } = this.state;
    var rent_id = document.getElementById("rent_id").value;

    const status = await contract.methods.checkAvailable( rent_id ).call({ from:accounts[0] });

    await contract.methods.restore( rent_id ).call({ from: accounts[0] });
  };

  //get total registered room
  getIndex = async () => {
    const { contract } = this.state;

    const response = await contract.methods.getIndex().call();
    this.setState({ totalRoom: response }, this.getTime);
  };

  getInfo = async () => {
    
    const { contract, accounts } = this.state;

    // Get the value from the contract to prove it worked.
    const response = await contract.methods.getAddress( count ).call();

    // this.setState({ storageValue: "Location: " + response[0] + "\n" + "Name: " + response[1] + '\n' + "Principal Name: " + response[2]});
    this.setState({storageValue:
      "Device ID: " + response[0] + '\n' +
      "Device Name: " + response[1] + '\n' +
      "Origin Owner: " + response[2] + '\n' +
      "Current Owner: " + response[3] + '\n' +
      "Previous Owner: " + response[4] + '\n' +
      "Status: " + response[5] + '\n'
    });

    if(response[1]!==""){
      if(count!==0){
        this.state.list.push(this.state.storageValue);
      }
    }

    if(response[1]!==""){
      if(count!==0){
        this.state.nameRoom.push(response[1]);
      }
    }
    
    //List all the registered device to list variable
    for(; count <= this.state.totalRoom ; count++){

      this.setState({}, this.getInfo);
    }
  };

  getTime = async() => {
    const { contract } = this.state;

    const response = await contract.methods.getTime( 1 ).call();
    this.state.timelist.push(response[0]);
    this.setState({ timelist: response[0] }, this.getInfo);
  };

  buildOptions() {
    var arr = [];

    for (let i = 1; i <= 10; i++) {
        arr.push(<option key={i} value="{i}">{i}</option>)
    }

    return arr; 
  }

  render() {
    var timestampArr = [];
    var name
    for(var i = 1; i<= 16; i++){
      timestampArr[i] = i;
    }
    for(var i = 0; i< this.state.totalRoom; i++){

    }
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        {/* REGISTER DEVICE */}
        <h2>Register Device</h2>
        <form onSubmit={this.register}>
          <label>
            Device Name:
            <input type="text" name="name" id="r_name"/><br></br>
            Device Price (Coin/hr):
            <input type="number" name="name" id="r_price"/><br></br>
          </label><br></br>
          <input type="submit" value="Submit" />
        </form>
        {/* RENT ROOM */}
        <h2>Rent Device</h2>
        <form onSubmit={this.rent}>
          <label>
            <label>Select Device: </label>
            <select id="rent_id">
              {/* {timestampArr.map((value, index) => {
                return <option value={value}>{value} Hour</option>
              })} */}
              <option value={-1}>---</option>
              {this.state.nameRoom.map((value, index) => (
                  <option value={index}>{value}</option>
              ))}
            </select>
            <br></br>
            <label>Start Time:</label>
          <DatePicker
            selected={this.state.startTime}
            onChange={this.handleChangeStart.bind(this)}
            showTimeSelect
            minDate={new Date()}
            dateFormat="d-MM-yyyy HH:mm"
          />
          <br></br>
        {/* <div>End Time: {this.state.startTime.toString()}</div> */}
        <label>How long will rent device:</label>
          <select id="r_timestamp" onChange={this.handleChangeTime.bind(this)}>
            {timestampArr.map((value, index) => {
              return <option value={value}>{value} Hour</option>
            })}
          </select>
          <br></br>
        <label>End Time:</label>
        <DatePicker
          selected={this.state.endTime}
          // onChange={this.handleChangeEnd.bind(this)}
          disabled={true}
          dateFormat="d-MM-yyyy HH:mm"
          placeholderText={this.state.endTime} />
          <br></br>
          </label>
          <br></br>
          <input type="submit" value="Submit" />
        </form>

        {/* test */}
        {/* <p>unix start time: {this.state.startTime.valueOf()}</p>
        <p>timestamp: {this.state.timestamp}</p>
        <p>unix end time: {this.state.endTime.valueOf()}</p>
        <p>test: {timetest}</p> */}
        {/* <p>timelist 0: {this.state.timelist}</p> */}
        {/* <p>index: {count}</p> */}
        {/* Seconds: {this.state.seconds} */}

        <h3>Current Address: {this.state.accounts[0]}</h3>
        <div>Stored data: {this.state.totalRoom}</div>
        <h3>Room Info</h3>
        {this.state.list.map(item => (
            <li key={item}>{item}</li>
        ))}
        {/* <h3>Room Name List</h3>
        {this.state.nameRoom.map(item => (
            <li key={item}>{item}</li>
        ))} */}
      </div>
    );
  }
}

export default App;