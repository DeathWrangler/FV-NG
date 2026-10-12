package Transactions
{
   import Classes.FeatureMessagingDefinition;
   import Classes.MapResource;
   import Classes.MultiRewardTreasurePayerLandBundleConstructionBuilding;
   import Classes.util.WorldIdUtil;
   import Engine.Classes.WorldObject;
   import Managers.FeatureMessagingManager;
   
   public class TTransformTreasureLandBundle extends TFarmTransaction
   {
      
      private var m_tiles:Array;
      
      private var m_transformOnComplete:Boolean;
      
      protected var m_successCallback:Function = null;
      
      protected var m_objects:Array = new Array();
      
      protected var m_savedObjects:Array = new Array();
      
      protected var m_bundleName:String;
      
      protected var m_featureName:String;
      
      public function TTransformTreasureLandBundle(tiles:Array, transformOnComplete:Boolean, bundleName:String, featureName:String, callBack:Function = null)
      {
         this.m_tiles = tiles;
         this.m_transformOnComplete = transformOnComplete;
         this.m_successCallback = callBack;
         this.m_bundleName = bundleName;
         this.m_featureName = featureName;
         super();
         this.setObjects();
      }
      
      private function setObjects() : void
      {
         var tileName:String = null;
         var worldObj:WorldObject = null;
         for(tileName in this.m_tiles)
         {
            worldObj = this.m_tiles[tileName];
            this.m_objects[tileName] = worldObj;
            if(this.m_objects[tileName] != null && this.m_objects[tileName].getId() == 0 && !Global.worldManager.isVisiting())
            {
               WorldIdUtil.assignTempIdToWorldObject(worldObj);
            }
            if(worldObj != null)
            {
               this.m_savedObjects.push(worldObj.getSaveObject());
            }
            else
            {
               this.m_savedObjects.push(null);
            }
         }
      }
      
      override public function perform() : void
      {
         signedCall("LandBundleService.buyLandBundle",this.m_savedObjects,this.m_bundleName);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var tileName:String = null;
         var featureDef:FeatureMessagingDefinition = null;
         var tileCompleteData:Object = null;
         var currentBuilding:MultiRewardTreasurePayerLandBundleConstructionBuilding = null;
         super.onComplete(result);
         if(result.hasOwnProperty("allfinishedItems"))
         {
            for(tileName in result["allfinishedItems"])
            {
               tileCompleteData = result["allfinishedItems"][tileName];
               if(this.m_tiles.hasOwnProperty(tileName))
               {
                  currentBuilding = this.m_tiles[tileName] as MultiRewardTreasurePayerLandBundleConstructionBuilding;
                  currentBuilding.transformBuilding(tileCompleteData);
                  currentBuilding.onFullyFinished(tileCompleteData);
                  if(this.m_objects[tileName] != null && (this.m_objects[tileName].getId() == 0 || this.m_objects[tileName].getId() >= WorldIdUtil.TEMP_ID_START) && tileCompleteData.hasOwnProperty("id") && tileCompleteData.id != 0)
                  {
                     this.m_objects[tileName].setId(tileCompleteData.id);
                  }
                  if(this.m_objects.hasOwnProperty(tileName) && tileCompleteData.hasOwnProperty("storageKey") && Boolean(this.m_objects[tileName] as MapResource))
                  {
                     (this.m_objects[tileName] as MapResource).attachToPersistentData(tileCompleteData["storageKey"]);
                  }
               }
            }
            featureDef = FeatureMessagingManager.getInstance().getFeatureDefinition(this.m_featureName);
            if(featureDef)
            {
               featureDef.updateIconVisibility();
            }
         }
      }
   }
}

