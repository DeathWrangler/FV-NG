package Classes.FeatureComponents
{
   import Classes.Constants.Experiments;
   import Classes.FeatureBuilding;
   import DataSources.BaseDataSource;
   import Engine.Helpers.Vector2;
   import Engine.Helpers.Vector3;
   import Managers.FarmGameSettingsManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.utils.Dictionary;
   
   public class TileRenderManager extends FeaturedRenderFManager
   {
      
      protected var m_propPoints:Array;
      
      private var deltaX:Dictionary;
      
      private var deltaY:Dictionary;
      
      private var m_xml:XML;
      
      private var _isDebug:Boolean = false;
      
      public function TileRenderManager(owner:FeatureBuilding)
      {
         var featureData:BaseDataSource = null;
         var propPoints:Array = null;
         var propPoint:BaseDataSource = null;
         var featuresXML:XMLList = null;
         var renderFeature:XMLList = null;
         var propPointsXML:XMLList = null;
         var propPointXML:XML = null;
         this.m_propPoints = [];
         this.deltaX = new Dictionary();
         this.deltaY = new Dictionary();
         super(owner);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureData = owner.getFarmItem().getFeatureDataByName(FeatureManager.RENDERING_FEATURE_NAME);
            if(featureData)
            {
               propPoints = featureData.getArray("propPoints","propPoint");
               for each(propPoint in propPoints)
               {
                  this.m_propPoints.push(new Vector2(propPoint.getNumber("x"),propPoint.getNumber("y")));
               }
            }
         }
         else
         {
            featuresXML = owner.getFarmItem().getFeaturesXML();
            renderFeature = featuresXML.(@name == FeatureManager.RENDERING_FEATURE_NAME);
            if(renderFeature != null)
            {
               propPointsXML = renderFeature.propPoints.propPoint;
               for each(propPointXML in propPointsXML)
               {
                  this.m_propPoints.push(new Vector2(Number(propPointXML.@x),Number(propPointXML.@y)));
               }
            }
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_DEV_GAMEBOARD_SETUP) > 0)
         {
            this._isDebug = true;
            this.instantiateDeltaValues();
            this.m_xml = <lootTable/>;
            this.m_xml.@name = owner.getItemName() + "_locations";
         }
      }
      
      private function get isDebug() : Boolean
      {
         return this._isDebug;
      }
      
      override public function updateDisplay() : void
      {
         var propIndex:int = 0;
         var propPoint:MovieClip = null;
         var propPointTilePos:Vector2 = null;
         if(owner.content is MovieClip)
         {
            for(propIndex = 0; propIndex < m_maxItems; propIndex++)
            {
               propPoint = new MovieClip();
               propPoint = this.positionPropPoint(propPoint,propIndex);
               owner.content[propPoint.name] = propPoint;
               (owner.content as DisplayObjectContainer).addChild(propPoint);
               if(this.isDebug)
               {
                  propPointTilePos = this.getPropPointTilePos(propIndex,owner.getFeaturedItems().length);
                  this.m_xml.appendChild(this.createLootItemXML(propPointTilePos));
               }
            }
         }
         super.updateDisplay();
         if(this.isDebug)
         {
         }
      }
      
      private function positionPropPoint(propPoint:MovieClip, index:int) : MovieClip
      {
         propPoint.x = this.m_propPoints[index].x;
         propPoint.y = this.m_propPoints[index].y;
         propPoint.name = m_propPointPrefix + "PropPoint_" + index.toString();
         return propPoint;
      }
      
      private function createLootItemXML(propPointPos:Vector2) : XML
      {
         var xml:XML = <lootItem/>;
         xml.@ignoreItemNameCheck = "true";
         xml.@xPos = propPointPos.x;
         xml.@yPos = propPointPos.y;
         return xml;
      }
      
      private function getPropPointTilePos(propPointIndex:int, itemsCount:int) : Vector2
      {
         var onwerTilePos:Vector3 = owner.getPosition();
         return new Vector2(onwerTilePos.x + this.deltaX[itemsCount][propPointIndex],onwerTilePos.y + this.deltaY[itemsCount][propPointIndex]);
      }
      
      private function instantiateDeltaValues() : void
      {
         this.deltaX[2] = new Array(8,24);
         this.deltaY[2] = new Array(8,11);
         this.deltaX[3] = new Array(8,24,16);
         this.deltaY[3] = new Array(8,11,23);
         this.deltaX[4] = new Array(8,24,23,7);
         this.deltaY[4] = new Array(8,11,23,24);
         this.deltaX[5] = new Array(8,24,31,15,7);
         this.deltaY[5] = new Array(8,11,23,24,24);
      }
   }
}

