var html = require("choo/html");
var choo = require("choo");

var app = choo();
app.use(dataStore);
app.route("/", mainView);
app.route("*", notFoundView);
app.mount("div#content");

function mainView (state, emit) {
    if(state.gottenData) {
        return html`
          <div id="content">
            <h1>Données pour notre maison</h1>

            <h2>Current Weather in Montreal</h1>
            <p>Summary: ${state.weather.summary}</p>
            <p>Currently: ${state.weather.temperature}°, Feels like: ${state.weather.apparentTemperature}°</p>
            <p>Humidity: ${state.weather.humidity * 100}%</p>

            <h2>System Status</h2>
            <p>Current front: ${state.front}</p>
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

function dataStore (state, emitter) {
    state.weather = {};
    state.front = "";
    state.gottenData = false;
    emitter.on("check_data", function () {
        fetch("/api/weather")
            .then(function (response) {
                response.json().then(function(data) {
                    state.weather = data.currently;
                });
            });

        fetch("/api/front")
            .then(function (response) {
                response.json().then(function(data) {
                    state.front = data.who;
                    state.gottenData = true;
                    emitter.emit("render");
                });
            });
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
