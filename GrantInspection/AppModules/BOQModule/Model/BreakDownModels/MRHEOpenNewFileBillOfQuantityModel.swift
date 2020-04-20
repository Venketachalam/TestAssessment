//
//  MRHEOpenNewFileBillOfQuantityModel.swift
//  Progress
//
//  Created by Muhammad Akhtar on 6/21/18.
//  Copyright © 2018 MBRHE. All rights reserved.
//

import Foundation

class MRHEOpenNewFileBillOfQuantityModel {
    
    var name: String!
    var percent: Float!
    var isEdited: Bool!
    var innerBreakDownObj = [MRHEOpenNewFileBillOfQuantityInnerObject]()
    var opened: Bool!
    
    init(name: String, isEdited: Bool, percent:Float, innerBreakDownObj:[MRHEOpenNewFileBillOfQuantityInnerObject], opened: Bool = false) {
        self.name = name
        self.percent = percent
        self.isEdited = isEdited
        self.innerBreakDownObj = innerBreakDownObj
        self.opened = opened
    }
    
    class func addDataIntoParentBOQObject() -> [MRHEOpenNewFileBillOfQuantityModel] {
        
        
        var tableData = [MRHEOpenNewFileBillOfQuantityModel]()
        // Mobilisation data
        
        // billofquantity_mobilisation = Mobilisation
        // billofquantity_mobilisation_mob_site_office = Mob.,Site office & Services.
        
      let siteOfficeObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0, workId: 11, workDesc: NSLocalizedString("billofquantity_mobilisation_mob_site_office", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [])
        let siteOfficeObjectArray = [siteOfficeObject]
        let mobilisationObj = MRHEOpenNewFileBillOfQuantityModel.init(name:NSLocalizedString("billofquantity_mobilisation", comment: ""), isEdited: false,percent: 0, innerBreakDownObj: siteOfficeObjectArray)
        
        
        // Excavation & Back filling data
        
        //billofquantity_excavation_and_back_filling = Excavation & Back filling
        //billofquantity_back_filling = Back filling
        //billofquantity_excavation = Excavation
        
        
      
      let ExcavationObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0, workId: 21, workDesc: NSLocalizedString("billofquantity_excavation", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      
      let BackFillingObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 22, workDesc: NSLocalizedString("billofquantity_back_filling", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      
        let ExcavationAndBackFillingArray = [ExcavationObject, BackFillingObject]
        let ExcavationAndBackFillingObj = MRHEOpenNewFileBillOfQuantityModel.init(name: NSLocalizedString("billofquantity_excavation_and_back_filling", comment: ""), isEdited: false,percent: 0, innerBreakDownObj: ExcavationAndBackFillingArray)
        
        //Sub structure data
        
        //billofquantity_sub_structure = Sub structure
        //billofquantity_sub_structure_villa_servent_block = Villa Servant block
        //billofquantity_sub_structure_villa_compound_block = Villa Compound wall
        //billofquantity_sub_structure_villa = Villa
        
      let villaObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 31, workDesc: NSLocalizedString("billofquantity_sub_structure_villa", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let villaCompoundWallObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 32, workDesc: NSLocalizedString("billofquantity_sub_structure_villa_compound_block", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let villaServantBlockObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 33, workDesc: NSLocalizedString("billofquantity_sub_structure_villa_servent_block", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
        
        let subStructureArray = [villaObject, villaCompoundWallObject, villaServantBlockObject]
        let subStructureObj = MRHEOpenNewFileBillOfQuantityModel.init(name: NSLocalizedString("billofquantity_sub_structure", comment: ""), isEdited: false,percent: 0, innerBreakDownObj: subStructureArray)
        
        //Super structure data
        
        //billofquantity_super_structure = Super structure
        //billofquantity_super_structure_servant_block = Servant block
        //billofquantity_super_structure_compound_wall = Compound wall
        //billofquantity_super_structure_villa_ff_slab = Villa FF slab
        //billofquantity_super_structure_villa_gf_slab = Villa GF slab
        
      let villaGFSlabObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 41, workDesc: NSLocalizedString("billofquantity_super_structure_villa_gf_slab", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let villaFFSlabObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 42, workDesc: NSLocalizedString("billofquantity_super_structure_villa_ff_slab", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let compoundWallObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 43, workDesc: NSLocalizedString("billofquantity_super_structure_compound_wall", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let servantBlockObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 44, workDesc: NSLocalizedString("billofquantity_super_structure_servant_block", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
        
        let superStructureArray = [villaGFSlabObject, villaFFSlabObject, compoundWallObject, servantBlockObject]
        let superStructureObj = MRHEOpenNewFileBillOfQuantityModel.init(name: NSLocalizedString("billofquantity_super_structure", comment: ""), isEdited: false,percent: 0, innerBreakDownObj: superStructureArray)
        
        //Block works data
        //billofquantity_block_works = Block works
        //billofquantity_block_works_servant_block = Servant block
        //billofquantity_block_works_compound_wall = Compound wall
        //billofquantity_block_works_villa_ff_walls = Villa FF walls
        //billofquantity_block_works_villa_gf_walls = Villa GF walls
        //billofquantity_block_works_solid_block = Solid block (Villa, C.W., S.B.)
        
      let solidBlockObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 51, workDesc: NSLocalizedString("billofquantity_block_works_solid_block", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let villaGFWallObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 52, workDesc: NSLocalizedString("billofquantity_block_works_villa_gf_walls", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let blockVillaFFWallObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 53, workDesc: NSLocalizedString("billofquantity_block_works_villa_ff_walls", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let blockCompoundWallObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 54, workDesc: NSLocalizedString("billofquantity_block_works_compound_wall", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let servantBlockWorksObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 55, workDesc: NSLocalizedString("billofquantity_block_works_servant_block", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
        
        let blockWorksArray = [solidBlockObject, villaGFWallObject, blockVillaFFWallObject, blockCompoundWallObject,servantBlockWorksObject]
        let blockWorksObj = MRHEOpenNewFileBillOfQuantityModel.init(name: NSLocalizedString("billofquantity_block_works", comment: ""), isEdited: false,percent: 0, innerBreakDownObj: blockWorksArray)
        
        
        //Plaster works
        
        //billofquantity_plaster_works = Plaster works
        //billofquantity_plaster_works_servant_block = Servant block
        //billofquantity_plaster_works_compound_wall = Compound wall
        //billofquantity_plaster_works_villa_external_plaster = Villa External plaster
        //billofquantity_plaster_works_villa_internal_plaster = Villa Internal plaster
        
      let villaInternalPlasterObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 61, workDesc: NSLocalizedString("billofquantity_plaster_works_villa_internal_plaster", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let villaExternalPlasterObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 62, workDesc: NSLocalizedString("billofquantity_plaster_works_villa_external_plaster", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let plasterCompoundWallObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 63, workDesc: NSLocalizedString("billofquantity_plaster_works_compound_wall", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let plasterWorksServentBlockObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 64, workDesc: NSLocalizedString("billofquantity_plaster_works_servant_block", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0 , comment: [String]())
        
        let plasterWorksArray = [villaInternalPlasterObject, villaExternalPlasterObject, plasterCompoundWallObject, plasterWorksServentBlockObject]
        let plasterWorksObj = MRHEOpenNewFileBillOfQuantityModel.init(name: NSLocalizedString("billofquantity_plaster_works", comment: ""), isEdited: false,percent: 0, innerBreakDownObj: plasterWorksArray)
        
        //Electrical works
        
        //billofquantity_electrical_works = Electrical works
        //billofquantity_electrical_works_light_fittings_fans = Light fittings & fans
        //billofquantity_electrical_works_accessories = Accessories
        //billofquantity_electrical_works_wiring = Wiring
        //billofquantity_electrical_works_conduits = Conduits
        
        
      let ConduitsObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 71, workDesc: NSLocalizedString("billofquantity_electrical_works_conduits", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let WiringObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 72, workDesc: NSLocalizedString("billofquantity_electrical_works_wiring", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let AccessoriesObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 73, workDesc: NSLocalizedString("billofquantity_electrical_works_accessories", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let LightFittingsFansObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 74, workDesc: NSLocalizedString("billofquantity_electrical_works_light_fittings_fans", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
        
        let electricalWorksArray = [ConduitsObject, WiringObject, AccessoriesObject, LightFittingsFansObject]
        let electricalWorksObj = MRHEOpenNewFileBillOfQuantityModel.init(name: NSLocalizedString("billofquantity_electrical_works", comment: ""), isEdited: false,percent: 0, innerBreakDownObj: electricalWorksArray)
        
        //Plumbing works (int.)
        
        //billofquantity_plumbing_works_internal = Plumbing works (int.)
        //billofquantity_plumbing_works_internal_sanitary_wares_water_heaters = Sanitary wares & water heaters
        //billofquantity_plumbing_works_internal_drainage_pipes = Drainage pipes
        //billofquantity_plumbing_works_internal_water_supply_pipes = Water supply pipes
        
      let waterSupplyPipesObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 81, workDesc: NSLocalizedString("billofquantity_plumbing_works_internal_water_supply_pipes", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let drainagePipesObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 82, workDesc: NSLocalizedString("billofquantity_plumbing_works_internal_drainage_pipes", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let sanitaryWaresAndWaterHeatersObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 83, workDesc: NSLocalizedString("billofquantity_plumbing_works_internal_sanitary_wares_water_heaters", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
        
        
        let plumbingWorksArray = [waterSupplyPipesObject, drainagePipesObject, sanitaryWaresAndWaterHeatersObject]
        let plumbingWorksObj = MRHEOpenNewFileBillOfQuantityModel.init(name: NSLocalizedString("billofquantity_plumbing_works_internal", comment: ""), isEdited: false,percent: 0, innerBreakDownObj: plumbingWorksArray)
        
        //Plumbing works (ext.)
        
        //billofquantity_plumbing_works_external = Plumbing works (ext.)
        //billofquantity_plumbing_works_external_septic_tank_soakaway = Septic tank and soakaway
        //billofquantity_plumbing_works_external_water_tanks_pumps = Water tanks & pumps
        //billofquantity_plumbing_works_external_drainage_pipes_manholes = Drainage pipes & manholes
        
      let drainagePipesAndManholesObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 91, workDesc: NSLocalizedString("billofquantity_plumbing_works_external_drainage_pipes_manholes", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let waterTanksAndPumpsObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 92, workDesc: NSLocalizedString("billofquantity_plumbing_works_external_water_tanks_pumps", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let septicTankAndSoakawayObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 93, workDesc: NSLocalizedString("billofquantity_plumbing_works_external_septic_tank_soakaway", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0  , comment: [String]())
        
        
        let plumbingWorksExtArray = [drainagePipesAndManholesObject, waterTanksAndPumpsObject, septicTankAndSoakawayObject]
        let plumbingWorksExtObj = MRHEOpenNewFileBillOfQuantityModel.init(name: NSLocalizedString("billofquantity_plumbing_works_external", comment: ""), isEdited: false,percent: 0, innerBreakDownObj: plumbingWorksExtArray)
        
        //Internal finishes
        
        //billofquantity_internal_finishes = Internal finishes
        //billofquantity_internal_finishes_false_ceiling_wet_area = False ceiling (wet area)
        //billofquantity_internal_finishes_marble = Marble
        //billofquantity_internal_finishes_paints = Paints
        //billofquantity_internal_finishes_wall_tiles = Wall tiles
        //billofquantity_internal_finishes_floor_tiles = Floor tiles
        
      let floorTilesObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 101, workDesc: NSLocalizedString("billofquantity_internal_finishes_floor_tiles", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let wallTilesObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 102, workDesc: NSLocalizedString("billofquantity_internal_finishes_wall_tiles", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let paintsObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 103, workDesc: NSLocalizedString("billofquantity_internal_finishes_paints", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let marbleObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 104, workDesc: NSLocalizedString("billofquantity_internal_finishes_marble", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let falseCeilingObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 105, workDesc: NSLocalizedString("billofquantity_internal_finishes_false_ceiling_wet_area", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
        
        let internalFinishesArray = [floorTilesObject, wallTilesObject, paintsObject, marbleObject, falseCeilingObject]
        let internalFinishesObj = MRHEOpenNewFileBillOfQuantityModel.init(name: NSLocalizedString("billofquantity_internal_finishes", comment: ""), isEdited: false,percent: 0, innerBreakDownObj: internalFinishesArray)
        
        //External finishes data
        
        //billofquantity_external_finishes = External finishes
        //billofquantity_external_finishes_marble = Marble
        //billofquantity_external_finishes_interlock = Interlock
        //billofquantity_external_finishes_compound_wall_paints = Compound Wall Paints
        //billofquantity_external_finishes_paints = Paints
        
      let externalPaintsObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 111, workDesc: NSLocalizedString("billofquantity_external_finishes_paints", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let externalCompoundWallPaintsObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 112, workDesc: NSLocalizedString("billofquantity_external_finishes_compound_wall_paints", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let externalInterlockObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 113, workDesc: NSLocalizedString("billofquantity_external_finishes_interlock", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let externalmarbleObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 114, workDesc: NSLocalizedString("billofquantity_external_finishes_marble", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
        
        let externalFinishesArray = [externalPaintsObject, externalCompoundWallPaintsObject, externalInterlockObject, externalmarbleObject]
        let externalFinishesObj = MRHEOpenNewFileBillOfQuantityModel.init(name: NSLocalizedString("billofquantity_external_finishes", comment: ""), isEdited: false,percent: 0, innerBreakDownObj: externalFinishesArray)
        
        //Water proofing
        
        //billofquantity_water_proofing = Water proofing
        //billofquantity_water_proofing_marble = Marble
        //billofquantity_water_proofing_bathrooms = Bathrooms
        //billofquantity_water_proofing_roof = Roof
        //billofquantity_water_proofing_footings = Footings (Villa, C.W., S.B.)
        
      let waterProofingFootingsObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 121, workDesc: NSLocalizedString("billofquantity_water_proofing_footings", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let waterProofingRoofObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 122, workDesc: NSLocalizedString("billofquantity_water_proofing_roof", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let waterProofingBathroomsObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 123, workDesc: NSLocalizedString("billofquantity_water_proofing_bathrooms", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let waterProofingMarbleObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 124, workDesc: NSLocalizedString("billofquantity_water_proofing_marble", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
        
        let waterProofingArray = [waterProofingFootingsObject, waterProofingRoofObject, waterProofingBathroomsObject, waterProofingMarbleObject]
        let waterProofingObj = MRHEOpenNewFileBillOfQuantityModel.init(name: NSLocalizedString("billofquantity_water_proofing", comment: ""), isEdited: false,percent: 0, innerBreakDownObj: waterProofingArray)
        
        //Aluminium Works
        
        //billofquantity_aluminium_works = Aluminium Works
        //billofquantity_aluminium_works_handrail = Handrail
        //billofquantity_aluminium_works_windows = Windows
        //billofquantity_aluminium_works_doors = Doors
        
      let aluminiumWorksDoorsObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 131, workDesc: NSLocalizedString("billofquantity_aluminium_works_doors", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let aluminiumWorkWindowssObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 132, workDesc: NSLocalizedString("billofquantity_aluminium_works_windows", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let aluminiumWorksHandrailObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 133, workDesc: NSLocalizedString("billofquantity_aluminium_works_handrail", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
        
        let aluminiumWorksArray = [aluminiumWorksDoorsObject, aluminiumWorkWindowssObject, aluminiumWorksHandrailObject]
        let aluminiumWorksObj = MRHEOpenNewFileBillOfQuantityModel.init(name: NSLocalizedString("billofquantity_aluminium_works", comment: ""), isEdited: false,percent: 0, innerBreakDownObj: aluminiumWorksArray)
        
        //Gates & Metal Works
        
        //billofquantity_gates_metal_works = Gates & Metal Works
        //billofquantity_gates_metal_works_spiral_stair = Spiral Stair
        //billofquantity_gates_metal_works_gates = Gates
        
      let gatesAndMetalWorksGatesObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 141, workDesc: NSLocalizedString("billofquantity_gates_metal_works_gates", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let gatesAndMetalWorksSpiralStairObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 142, workDesc: NSLocalizedString("billofquantity_gates_metal_works_spiral_stair", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
        
        let gatesAndMetalWorksArray = [gatesAndMetalWorksGatesObject, gatesAndMetalWorksSpiralStairObject]
        let gatesAndMetalWorksObj = MRHEOpenNewFileBillOfQuantityModel.init(name: NSLocalizedString("billofquantity_gates_metal_works", comment: ""), isEdited: false,percent: 0, innerBreakDownObj: gatesAndMetalWorksArray)
        
        //Joinery works
        //billofquantity_joinery_works = Joinery works
        //billofquantity_joinery_works_kitchen_cabinets_wardrobes = Kitchen cabinets and wardrobes
        //billofquantity_joinery_works_doors = Doors
        
        
      let joineryWorksDoorsObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 151, workDesc: NSLocalizedString("billofquantity_joinery_works_doors", comment: ""), contarctPercentage: 0, actualDone: 0   , paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let joineryWorksKitchenCabinetsAndWardrobesObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 152, workDesc: NSLocalizedString("billofquantity_joinery_works_kitchen_cabinets_wardrobes", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
        
        let joineryWorksArray = [joineryWorksDoorsObject, joineryWorksKitchenCabinetsAndWardrobesObject]
        let joineryWorksObj = MRHEOpenNewFileBillOfQuantityModel.init(name: NSLocalizedString("billofquantity_joinery_works", comment: ""), isEdited: false,percent: 0, innerBreakDownObj: joineryWorksArray)
        
        //Air conditioning works
        //billofquantity_air_conditioning_works = Air conditioning works
        //billofquantity_air_conditioning_works_ducts_diffusers = Ducts/diffusers
        //billofquantity_air_conditioning_works_machines_unit = Machines/unit
        
      let airConditioningWorksMachinesUnitObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 161, workDesc: NSLocalizedString("billofquantity_air_conditioning_works_machines_unit", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
      let  airConditioningWorksDuctsDiffusersObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 162, workDesc: NSLocalizedString("billofquantity_air_conditioning_works_ducts_diffusers", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0 , comment: [String]())
        
        let airConditioningWorksArray = [airConditioningWorksMachinesUnitObject, airConditioningWorksDuctsDiffusersObject]
        let airConditioningWorksObj = MRHEOpenNewFileBillOfQuantityModel.init(name: NSLocalizedString("billofquantity_air_conditioning_works", comment: ""), isEdited: false,percent: 0, innerBreakDownObj: airConditioningWorksArray)
        
        //Cleaning
        //billofquantity_cleaning = Cleaning
        //billofquantity_cleaning_cleaning_leveling_handing_over = Cleaning, leveling & handing over
        
      let cleanLevelingObject = MRHEOpenNewFileBillOfQuantityInnerObject.init(paymentDetailId: 0,workId: 171, workDesc: NSLocalizedString("billofquantity_cleaning_cleaning_leveling_handing_over", comment: ""), contarctPercentage: 0, actualDone: 0, paymentPercentage: 0, engineerPercentage: 0, comment: [String]())
        
        let cleaningArray = [cleanLevelingObject]
        let cleaningObj = MRHEOpenNewFileBillOfQuantityModel.init(name: NSLocalizedString("billofquantity_cleaning", comment: ""), isEdited: false,percent: 0, innerBreakDownObj: cleaningArray)
        
        tableData.append(mobilisationObj)
        tableData.append(ExcavationAndBackFillingObj)
        tableData.append(subStructureObj)
        tableData.append(superStructureObj)
        tableData.append(blockWorksObj)
        tableData.append(plasterWorksObj)
        tableData.append(electricalWorksObj)
        tableData.append(plumbingWorksObj)
        tableData.append(plumbingWorksExtObj)
        tableData.append(internalFinishesObj)
        tableData.append(externalFinishesObj)
        tableData.append(waterProofingObj)
        tableData.append(aluminiumWorksObj)
        tableData.append(gatesAndMetalWorksObj)
        tableData.append(joineryWorksObj)
        tableData.append(airConditioningWorksObj)
        tableData.append(cleaningObj)
        
        return tableData
        
    }
    
}

