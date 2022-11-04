import yellowline from "../data/yellowline.json" assert { type : 'json'}
import kbr from "../data/keybusroutes.geojson" assert {type : 'json'}
import stops from "../data/stops.js"

let keybusroutes = kbr[0].features

let YL = yellowline.features;

const mapboxAccount = 'mapbox';
const mapboxStyle = 'light-v10';
const mapboxToken = 'pk.eyJ1IjoicHJvbWNoYXQiLCJhIjoiY2w4dzFtbHkyMDJwbTN2b2szanl0aWV0NSJ9.1z0LR6gywZcgz7D21JSdcA'

var filteredRoutes = []

let plot = []

for ( let i of YL ){

    plot.push(i)
   
}

//map.invalidate

let routeMap = L.map('basemap').setView([42.3601, -71.0589], 12);
let compareMap = L.map('compare-map').setView([42.3601, -71.0589], 12);

const toggleBPT1 = document.getElementById("bpt1")
const toggleBPT0 = document.getElementById("bpt0")
const toggleBPT2 = document.getElementById("bpt2")

const toggleComp = document.getElementById("comp")
const compMap = document.getElementById("compare-map")
const mainMap = document.getElementById("basemap")
const panel = document.getElementById("panel")

const talk = document.getElementById("talk")

const saveButton = document.getElementById("save-button")


function showRoutes(route, map, col1, col2){

    let active = 0;

    if(map.active !== undefined){
        map.removeLayer(map.active);
    }

    
    //L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      //  attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        //}).addTo(map);

    

    L.tileLayer(`https://api.mapbox.com/styles/v1/promchat/cl9xkypa8000p14nwki6k3a69/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoicHJvbWNoYXQiLCJhIjoiY2w4dzFtbHkyMDJwbTN2b2szanl0aWV0NSJ9.1z0LR6gywZcgz7D21JSdcA`, {
            maxZoom: 19,
            attribution: '© <a href="https://www.mapbox.com/about/maps/">Mapbox</a> © <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> <strong><a href="https://www.mapbox.com/map-feedback/" target="_blank">Improve this map</a></strong>',
        }).addTo(map);

    map.active = L.geoJson(route, { style : function (feature){
        switch (feature.properties.BsPrrty){
            case 1 : return {color: col1};
            case 0 : return {color: col2};
        }
    }, 
                onEachFeature: function (feature, layer) {
                layer.bindPopup("ROUTE" + feature.properties.ROUTE + "..." +" BUS PRIORITY TREATMENT " + feature.properties.BsPrrty);
            }
    }).addTo(map);

 }

 showRoutes(plot, routeMap, '#611f69', '#611f69');
 showRoutes(plot, compareMap, '#611f69', '#611f69');

//L.marker([51.5, -0.09]).addTo(map);

//var polyline = L.polyline(yellowline, {color: 'red'}).addTo(map);

//L.geoJSON(plot).addTo(map).bindPopup(layer => layer.properties.ROUTE).openPopup();


 toggleBPT1.addEventListener('click', (evt) => {

    if(toggleBPT1.checked){
    console.log('started');
    filteredRoutes = plot.filter(busPriorityTrue);
    console.log(filteredRoutes)
    showRoutes(filteredRoutes, routeMap, '#2EB67D', '#E01E5A'); }  
    else{
        showRoutes(plot, routeMap, '#611f69', '#611f69');
    }     

 });

 toggleBPT0.addEventListener('click', (evt) => {

    if(toggleBPT0.checked){
    console.log('started');
    filteredRoutes = plot.filter(busPriorityFalse);
    console.log(filteredRoutes)
    showRoutes(filteredRoutes, routeMap, '#2EB67D', '#E01E5A'); }  
    else{
        showRoutes(plot, routeMap, '#611f69', '#611f69');
    }     

 });

 toggleBPT2.addEventListener('click', (evt) => {

    if(toggleBPT2.checked){
    console.log('started');
    showRoutes(plot, routeMap, '#2EB67D', '#E01E5A'); }  
    else{
        showRoutes(plot, routeMap, '#611f69', '#611f69');
    } 
   
 });


 toggleComp.addEventListener('click', (evt) => {

    console.log('Compare Mode')
    if (compMap.style.display !== "none") {
        compMap.style.display = "none";

      } else {
        compMap.style.display = "block";

        }
   
 });

 talk.addEventListener('input', () =>{

    console.log(talk.value)

 });

 function busPriorityTrue(route){
    console.log('Checking BP')
    return (route.properties.BsPrrty === 1);
 }

 function busPriorityFalse(route){
    console.log('Checking BP')
    return (route.properties.BsPrrty === 0);
 }

 function route_color(bpt){
    if(bpt === 1) return "#611f69";
    if(bpt === 0) return "red";
 }

 function route_style(feature){
    console.log('Style change')
    return{
        "fillColor": route_color(feature.properties.BsPrrty),
        "weight": 1,
    };
 }


// 82% reliability interpreted in terms of minutes? Planner vs Public perspective so reliability + atual delay ; headway ; avg wait time + scheduled frequency
// basemap tile change 
// bus priority toggle
// OTP + bus prioirty
// the combinations and talk about why
// slide about intended user
// scheduled peak headway
// these are ability to change the symbology of the base layer (eg socioeconomic data, demographic)
// exmaple of when a community demanded seomthing based on performance // failed example is silver line // mitigation from big dig and green 
// ways in which mitigation funding
// we would propose
// route 1 is bad because... as a result this community should use our tool to demand bus prioirity because other routes have seen good performance therefore...

window.yellowline = yellowline
window.stops = stops
window.kbr = kbr
window.YL = YL
window.plot = plot