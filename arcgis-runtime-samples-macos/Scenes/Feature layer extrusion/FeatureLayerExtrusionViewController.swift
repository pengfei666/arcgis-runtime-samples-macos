//
// Copyright 2017 Esri.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Cocoa
import ArcGIS

class FeatureLayerExtrusionViewController: NSViewController {

    @IBOutlet weak var extrusionControl: NSSegmentedControl!
    @IBOutlet weak var sceneView: AGSSceneView!
    // initialize scene with the topographic basemap
    let scene = AGSScene(basemapType: .topographic)

    // US census data feature service
    let statesService = "https://sampleserver6.arcgisonline.com/arcgis/rest/services/Census/MapServer/3"
    var renderer : AGSRenderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.sceneView.scene = scene
        
        // create service feature table from US census feature service
        let table = AGSServiceFeatureTable(url: URL(string: statesService)!)
        // create feature layer from service feature table
        let layer = AGSFeatureLayer(featureTable: table)
        // feature layer must be rendered dynamically for extrusion to work
        layer.renderingMode = .dynamic
        // setup the symbols used to display the features (US states) from the table
        let lineSymbol = AGSSimpleLineSymbol(style:.solid, color:NSColor.blue, width:1.0)
        let fillSymbol = AGSSimpleFillSymbol(style:.solid, color:NSColor.blue, outline:lineSymbol)
        renderer = AGSSimpleRenderer(symbol: fillSymbol)
        // need to set an extrusion type, BASE HEIGHT extrudes each point from the feature individually
        renderer?.sceneProperties?.extrusionMode = .baseHeight
        
        // set the extrusion to total population
        renderer?.sceneProperties?.extrusionExpression = "[POP2007]/ 10"
        extrusionControl.selectedSegment = 0

        // set the renderer on the layer and add the layer to the scene
        layer.renderer = renderer
        self.scene.operationalLayers.add(layer)
        
        // set the initial view
        let initialLocation = AGSPoint(x: -98.585522, y: 70, spatialReference: sceneView.spatialReference)
        let orbitCamera = AGSOrbitLocationCameraController(targetLocation: initialLocation, distance: 15000000)
        orbitCamera.cameraPitchOffset = 75.0
        sceneView.cameraController = orbitCamera

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func extrusionAction(_ sender: NSSegmentedControl) {
        // button action for extruding by total population or by population density
        switch sender.selectedSegment {
        case 0:
            renderer?.sceneProperties?.extrusionExpression = "[POP2007]/ 10"
        case 1:
            renderer?.sceneProperties?.extrusionExpression = "[POP07_SQMI] * 5000"
        default:
            renderer?.sceneProperties?.extrusionExpression = ""
        }
    }
    
}
