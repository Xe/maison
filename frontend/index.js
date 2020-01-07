var html = require("choo/html");
var choo = require("choo");

var app = choo();
app.use(dataStore);
app.route("/", mainView);
app.route("*", notFoundView);
app.use(updateLoop);
app.mount("div#content");

function updateLoop (state, emitter) {
    console.log("scheduling updates every 3 minutes");
    setInterval(function() {
        emitter.emit("check_data");
    }, 180000);
    setInterval(function() {
        state.currentTime = now();
    }, 30000);
}

function mainView (state, emit) {
    if(state.gottenData) {
        document.body.style.backgroundImage = `url('/img/${state.front.toLowerCase()}.png')`;
        return html`
          <div id="content" onclick=${onclick}>
            <h2>Current Weather in Montreal</h2>
            <table>
              <tr>
                <td>
                  <p>
                    <span id="feels">${state.weather.currently.summary}</span><br />
                    H/L: ${Math.round(state.weather.daily.data[0].temperatureHigh)}°C/${Math.round(state.weather.daily.data[0].temperatureLow)}°C<br />
                    Feels like: ${Math.round(state.weather.currently.apparentTemperature)}°C<br />
                    Humidity: ${state.weather.currently.humidity * 100}%<br />
                    ${state.weather.daily.summary}
                  </p>
                </td>
                <td class="currently">
                  <p>${Math.round(state.weather.currently.temperature)}</p>
                </td>
              </tr>
            </table>
            <p>${state.weather.daily.summary}</p>

            <h2>System Status</h2>
            <p>
              Current front: ${state.front}<br />
              Last updated at ${state.now}<br />
              <span class="currently">${state.currentTime}</span>
            </p>
          </div>
        `;
    } else {
        onclick();
        return html`
          <div id="content">
            <p>Loading...</p>
            <button onclick=${onclick}>Get Data</button>
          </div>
        `;
    }

    function onclick () {
        emit("check_data");
    }
}

function jsonOf(route) {
    return fetch(route).then(response => response.json());
}

function now() {
    let today = new Date();
    return today.getHours() + ":" + today.getMinutes();
}

function dataStore (state, emitter) {
    state.now = "";
    state.weather = {};
    state.front = "";
    state.gottenData = false;
    state.currentTime = now();
    emitter.on("check_data", async function () {
        console.log("got more data");
        let today = new Date();
        state.now = now();
        state.weather = (await jsonOf("/api/weather"));
        state.front = (await jsonOf("/api/front")).who;
        state.gottenData = true;
        emitter.emit("render");
    });
}

function notFoundView (state, emit) {
    return html`
      <div id="content">
        <h1>Oh no, we can't find ${state.href}</h1>

        <p>Try going back <a href="/">to the root</a>.</p>
      </div>
    `;
}
