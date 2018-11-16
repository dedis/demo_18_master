require("babel-core/register");
require("babel-polyfill");
var $ = require('jquery');

var Highcharts = require('highcharts');

// Load module after Highcharts is loaded
require('highcharts/modules/exporting')(Highcharts);

var Buffer = require('buffer/').Buffer;
var Log = require('./log.js').Log;
var cothority = require('@dedis/cothority');

Log.print("starting", cothority);
const net = cothority.net; // the network module
const serverAddress = "ws://192.168.0.42:7773";
const bcID = new Uint8Array(Buffer.from('19f6b8533d9fd984a10b074d2bdfeacb0aa5b23edcb54cbb9aac2c2aeaf61d4d', 'hex'));
const socket = new net.Socket(serverAddress, "ByzCoin"); // socket to talk to a conode
Log.print("socket:", socket);
global.Buffer = Buffer;

Uint8Array.prototype.hex = function() {
  return Buffer.from(this).toString('hex');
}

$(() => {
  nodesChart = setupNodesChart();
  tpsChart = setupTpsChart();
});

cothority.byzcoin.ByzCoinRPC.fromKnownConfiguration(socket, bcID)
  .then((bc) => {
    Log.print("Got byzcoin");
    global.bc = bc
    updateCharts();
    return bc.getProof(new Uint8Array(32));
  })
  .then((p) => {
    Log.print("Got proof");
    global.proof = p;
  })
  .catch(err => {
    Log.catch(err);
  });


var nodes = [];
var tpsInst = [];
var tpsMean = [];
var deleteNode = 1;
var nodesLen = 10;

function setupNodesChart() {
  return Highcharts.chart('nodes', {
    title: {
      text: 'Number of nodes'
    },
    yAxis: {
      title: {
        text: 'Nodes in the roster'
      }
    },
    series: [{
      name: 'Nodes',
      data: nodes
    }]
  });
}

function setupTpsChart() {
  return Highcharts.chart('tps', {
    title: {
      text: 'Transactions per second'
    },
    yAxis: {
      title: {
        text: 'Transactions'
      }
    },
    series: [{
      name: 'Instantaneous',
      data: tpsInst
    }, {
      name: 'Overall',
      data: tpsMean
    }]
  });
}

var lastBlock = -1;
var transactions = 0;
var duration = 0;

function updateCharts() {
  chartInterval = 5;
  duration += chartInterval;
  global.bc.skipchain.getLatestBlock()
    .then(bl => {
      nodes.push(bl.roster.list.length);
      updateRoster(bl.roster.list);
      updateStatus(bl);
      let txs = 0;
      if (bl.index > lastBlock) {
        lastBlock = bl.index;
        const bodyModel = cothority.protobuf.root.lookup("DataBody");
        let body = bodyModel.decode(bl.payload);
        txs = body.txresults.length
        Log.print("Got new block with index:", bl.index, txs);
      }
      tpsInst.push(txs / chartInterval);
      transactions += txs;
      tpsMean.push(transactions / duration);
      if (nodes.length > nodesLen) {
        d = nodesLen / 2;
        for (let c = deleteNode; c % 2 == 0; c = c >> 1) {
          d--;
        }
        if (d == 1) {
          deleteNode = 1;
        }
        nodes.splice(d, 1);
        let ti = tpsInst.splice(d, 1);
        tpsInst[d - 1] += ti;
        tpsMean.splice(d, 1);
        deleteNode++;
        if (deleteNode > Math.pow(nodesLen / 2, 2)) {
          deleteNode = 1;
        }
      }
      nodesChart.series[0].setData(nodes.slice());
      tpsChart.series[0].setData(tpsInst.slice());
      tpsChart.series[1].setData(tpsMean.slice());
    })
    .catch(err => {
      Log.catch(err);
    })
    .finally(() => {
      setTimeout(() => {
        updateCharts();
      }, chartInterval * 1000);
    })
}

function tlsToWs(addr) {
  let as = addr.split(':')
  return "ws:" + as[1] + ":" + (parseInt(as[2]) + 1);
}

function updateRoster(list) {
  return Promise.all(list.map(si => {
      const socketStatus = new net.Socket(tlsToWs(si.address), "Status"); // socket to talk to a conode
      return socketStatus.send("status.Request", "Response", {})
        .catch(err => {
          Log.catch(err);
          return si;
        })
    }))
    .then(statuses => {
      list = statuses.map((si, i) => {
        let stat = "FAIL";
        if (si.serveridentity) {
          stat = " ok ";
          si = si.serveridentity;
        }
        return stat + " - " + si.address + " - " + si.description;
      });
      $('#roster').html("<pre>Roster is:\n" + list.join("\n") + "</pre>");
    })
}

function updateStatus(sb) {
  let stat = ["# blocks: " + sb.index,
    "# backlinks: " + sb.backlinks.length,
    "block-size: " + (sb.data.length + sb.payload.length)
  ];
  $('#status').html("<pre>" + stat.join("\n") + "</pre>")
}

global.hex2iid = function(h) {
  return new Uint8Array(Buffer.from(h, 'hex'));
}

global.value2coin = function(data) {
  const coinModel = cothority.protobuf.root.lookup("Coin");
  return coinModel.decode(data);
}
