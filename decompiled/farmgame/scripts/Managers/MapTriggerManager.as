package Managers
{
   import Classes.AFInnovationMapTrigger;
   import Classes.AmsterdamInnovationMapTrigger;
   import Classes.AnimalSanctuaryMapTrigger;
   import Classes.AnimalSanctuaryV2MapTrigger;
   import Classes.AntiqueMuseumMapTrigger;
   import Classes.AntiqueMuseumV2MapTrigger;
   import Classes.BackgroundAnimationDecoMapTrigger;
   import Classes.BoatRushFlagMapTrigger;
   import Classes.BoatRushMapTrigger;
   import Classes.BobBerryFarmMapTrigger;
   import Classes.BoraBoraInnovationMapTrigger;
   import Classes.BringBackWinterMapTrigger;
   import Classes.CanadaInnovationMapTrigger;
   import Classes.CarribeanInnovationFranchiseMapTrigger;
   import Classes.CarribeanInnovationMapTrigger;
   import Classes.CasablancaInnovationFranchiseMapTrigger;
   import Classes.CasablancaInnovationMapTrigger;
   import Classes.ChangeStateOnHoverMapTrigger;
   import Classes.DailyCheckInMapTrigger;
   import Classes.Dec19InnovationMapTrigger;
   import Classes.DialogMapTrigger;
   import Classes.FarmRun2018MapTrigger;
   import Classes.FarmRunV5MapTrigger;
   import Classes.FarmRunV7MapTrigger;
   import Classes.FarmersMarketInnovationMapTrigger;
   import Classes.FishingV2MapTrigger;
   import Classes.FreeTrialMapTrigger;
   import Classes.FrontierInnovationMapTrigger;
   import Classes.GypsyTraderMapTrigger;
   import Classes.Halloween2019InnovationMapTrigger;
   import Classes.HalloweenInnovationGhoulMapTrigger;
   import Classes.HalloweenUSAInnovationMapTrigger;
   import Classes.Idle.GenericCallbackIdleTask;
   import Classes.Idle.IdleTaskQueue;
   import Classes.IrelandInnovationMapTrigger;
   import Classes.IsraelInnovationMapTrigger;
   import Classes.MOTDMapTrigger;
   import Classes.MadagascarInnovationMapTrigger;
   import Classes.MapTrigger;
   import Classes.OctoberSidecarFeatureMapTrigger;
   import Classes.OlyInnovationMapTrigger;
   import Classes.PumpkinPartyInnovationMapTrigger;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.QuestChainMapTrigger;
   import Classes.RecurringQuestChainMapTrigger;
   import Classes.RegionMapTrigger;
   import Classes.RussiaInnovationMapTrigger;
   import Classes.SouthindiaInnovationMapTrigger;
   import Classes.SubmergingElelephantMapTrigger;
   import Classes.SubscriberWalletMapTrigger;
   import Classes.SubscriberWalletMapTriggerFAQ;
   import Classes.TieredQuestChainMapTrigger;
   import Classes.TropicalMarketInnovationMapTrigger;
   import Classes.TuscanyInnovationMapTrigger;
   import Classes.TwentiesInnovationMapTrigger;
   import Classes.WanderingPirateMapTrigger;
   import Classes.WhitewinterInnovationMapTrigger;
   import Classes.WinterRacingFeatureRacingFlagMapTrigger;
   import Classes.WinterRacingFeatureRacingMapTrigger;
   import Classes.WinternordInnovationMapTrigger;
   import Classes.WorldTravelMapTrigger;
   import Classes.WreathFestivalInnovationMapTrigger;
   import Engine.Helpers.Vector3;
   import Engine.Managers.ErrorManager;
   import flash.utils.getDefinitionByName;
   
   public class MapTriggerManager
   {
      
      private static var m_instance:MapTriggerManager = null;
      
      private static var m_canInstantiate:Boolean = false;
      
      private var m_mapTriggers:Vector.<MapTrigger> = null;
      
      private var m_triggerName:String;
      
      private var m_mapTriggerXML:XML = null;
      
      protected var m_mapTriggerTypes:Array = [MapTrigger,QuestChainMapTrigger,MOTDMapTrigger,WorldTravelMapTrigger,FreeTrialMapTrigger,DialogMapTrigger,GypsyTraderMapTrigger,BringBackWinterMapTrigger,RecurringQuestChainMapTrigger,TieredQuestChainMapTrigger,DailyCheckInMapTrigger,BobBerryFarmMapTrigger,WanderingPirateMapTrigger,FarmRun2018MapTrigger,SubmergingElelephantMapTrigger,WhitewinterInnovationMapTrigger,ChangeStateOnHoverMapTrigger,RegionMapTrigger,OlyInnovationMapTrigger,SubscriberWalletMapTriggerFAQ,AFInnovationMapTrigger,HalloweenUSAInnovationMapTrigger,SubscriberWalletMapTrigger,TuscanyInnovationMapTrigger,RussiaInnovationMapTrigger,IsraelInnovationMapTrigger,CarribeanInnovationMapTrigger,CarribeanInnovationFranchiseMapTrigger,FrontierInnovationMapTrigger,HalloweenInnovationGhoulMapTrigger,WinternordInnovationMapTrigger,TwentiesInnovationMapTrigger,SouthindiaInnovationMapTrigger,Dec19InnovationMapTrigger,CasablancaInnovationMapTrigger,CasablancaInnovationFranchiseMapTrigger,BackgroundAnimationDecoMapTrigger
      ,IrelandInnovationMapTrigger,FarmRunV5MapTrigger,FishingV2MapTrigger,Halloween2019InnovationMapTrigger,AntiqueMuseumMapTrigger,WinterRacingFeatureRacingMapTrigger,WinterRacingFeatureRacingFlagMapTrigger,AnimalSanctuaryMapTrigger,FarmRunV7MapTrigger,FarmersMarketInnovationMapTrigger,MadagascarInnovationMapTrigger,BoraBoraInnovationMapTrigger,AnimalSanctuaryV2MapTrigger,AmsterdamInnovationMapTrigger,AntiqueMuseumV2MapTrigger,CanadaInnovationMapTrigger,PumpkinPartyInnovationMapTrigger,CanadaInnovationMapTrigger,BoatRushMapTrigger,BoatRushFlagMapTrigger,TropicalMarketInnovationMapTrigger,WreathFestivalInnovationMapTrigger,OctoberSidecarFeatureMapTrigger];
      
      public function MapTriggerManager()
      {
         super();
         if(!m_canInstantiate)
         {
            throw new Error("Cannot call constructor directly - use getInstance() instead.");
         }
      }
      
      public static function getInstance() : MapTriggerManager
      {
         if(null == m_instance)
         {
            m_canInstantiate = true;
            m_instance = new MapTriggerManager();
            m_canInstantiate = false;
         }
         return m_instance;
      }
      
      public function getMapTriggerByName(name:String) : MapTrigger
      {
         var mapTrigger:MapTrigger = null;
         var result:MapTrigger = null;
         for each(mapTrigger in this.m_mapTriggers)
         {
            if(mapTrigger.name == name)
            {
               result = mapTrigger;
               break;
            }
         }
         return result;
      }
      
      public function loadMapTriggerXML(mapTriggerXml:XML) : void
      {
         this.m_mapTriggerXML = mapTriggerXml;
      }
      
      public function removeAllMapTriggers() : void
      {
         var oldMapTrigger:MapTrigger = null;
         for each(oldMapTrigger in this.m_mapTriggers)
         {
            if(oldMapTrigger != null)
            {
               oldMapTrigger.detach();
               oldMapTrigger.cleanUp();
               oldMapTrigger = null;
            }
         }
      }
      
      public function createMapTriggers() : void
      {
         var mapTriggerXmlList:XMLList = null;
         var mapTriggerXmlData:XML = null;
         var mapTrigger:MapTrigger = null;
         this.removeAllMapTriggers();
         if(!Global.worldManager.isVisitingNPC() && this.m_mapTriggerXML != null)
         {
            this.m_mapTriggers = new Vector.<MapTrigger>();
            if(this.m_mapTriggerXML.children().length() > 0)
            {
               mapTriggerXmlList = this.m_mapTriggerXML.children();
               for each(mapTriggerXmlData in mapTriggerXmlList)
               {
                  if(mapTriggerXmlData.name() == "mapTrigger" && mapTriggerXmlData.attribute("itemName") != "")
                  {
                     if(this.checkPrereqs(mapTriggerXmlData))
                     {
                        mapTrigger = this.createMapTrigger(mapTriggerXmlData);
                        this.m_mapTriggers.push(mapTrigger);
                     }
                  }
               }
            }
         }
      }
      
      private function createMapTrigger(mapTriggerXmlData:XML) : MapTrigger
      {
         var classObj:Class;
         var mapTrigger:MapTrigger = null;
         var itemName:String = null;
         var className:String = null;
         var startingState:String = null;
         var xPercent:String = null;
         var yPercent:String = null;
         var xOffset:String = null;
         var yOffset:String = null;
         var activeQuest:FarmQuest = null;
         var callback:Function = null;
         itemName = mapTriggerXmlData.attribute("itemName").toString();
         className = mapTriggerXmlData.attribute("class").toString();
         if(className == "")
         {
            className = "MapTrigger";
         }
         classObj = null;
         try
         {
            classObj = getDefinitionByName("Classes." + className) as Class;
         }
         catch(error:Error)
         {
            ErrorManager.addError("Type is not found " + className,ErrorManager.ERROR_REMOTEOBJECT_FAULT);
         }
         if(null != classObj)
         {
            startingState = mapTriggerXmlData.attribute("state").toString();
            if(startingState == "")
            {
               mapTrigger = new classObj(itemName) as MapTrigger;
            }
            else
            {
               mapTrigger = new classObj(itemName,startingState) as MapTrigger;
            }
            this.m_triggerName = mapTriggerXmlData.attribute("name").toString();
            if(mapTriggerXmlData.hasOwnProperty("data") && mapTriggerXmlData.data.hasOwnProperty("dialogUrl"))
            {
               mapTrigger.dialogUrl = mapTriggerXmlData.data.dialogUrl;
            }
            if(this.m_triggerName != "")
            {
               mapTrigger.name = this.m_triggerName;
            }
            mapTrigger.loadObject(null);
            if(mapTriggerXmlData.child("data").length() != 0)
            {
               mapTrigger.loadXmlData(mapTriggerXmlData.child("data")[0]);
            }
            xPercent = mapTriggerXmlData.attribute("xPercent").toString();
            yPercent = mapTriggerXmlData.attribute("yPercent").toString();
            xOffset = mapTriggerXmlData.attribute("xOffset").toString();
            yOffset = mapTriggerXmlData.attribute("yOffset").toString();
            if(mapTriggerXmlData.hasOwnProperty("data") && mapTriggerXmlData.data.hasOwnProperty("worldSpecific"))
            {
               if(mapTriggerXmlData.data.worldSpecific.attribute("world").toString() == Global.worldManager.currentWorldType)
               {
                  xOffset = mapTriggerXmlData.data.worldSpecific.attribute("xOffset").toString();
                  yOffset = mapTriggerXmlData.data.worldSpecific.attribute("yOffset").toString();
               }
            }
            this.setMapTriggerPosition(mapTrigger,parseInt(xPercent),parseInt(yPercent),parseInt(xOffset),parseInt(yOffset));
            if(mapTrigger.isAttached())
            {
               mapTrigger.conditionallyReattach(true);
            }
            if(mapTrigger is QuestChainMapTrigger)
            {
               activeQuest = ContextMenuQuestManager.instance.getQuestForItemName(itemName);
               if(Boolean(activeQuest) && (activeQuest.questNumber > 1 || activeQuest.numOfCompletedTasks > 1))
               {
                  callback = function():void
                  {
                     ContextMenuQuestManager.instance.conditionallyShowActivationToaster(itemName);
                  };
                  IdleTaskQueue.getInstance().addTask(new GenericCallbackIdleTask(callback,ContextMenuQuestManager.MAP_TRIGGER_REACTIVATION_IDLE_TASK_DELAY));
               }
            }
         }
         return mapTrigger;
      }
      
      public function getMapTriggerName() : String
      {
         return this.m_triggerName;
      }
      
      private function checkPrereqs(mapTriggerXmlData:XML) : Boolean
      {
         var prereq:Object = null;
         var prereqs:Array = null;
         var preReqXML:XML = mapTriggerXmlData.child("prereqs")[0];
         if(preReqXML.length() != 0)
         {
            prereqs = PrerequisiteUtility.parseXmlNodePrereqs(preReqXML[0].prereq);
         }
         var validMapTrigger:Boolean = true;
         if(prereqs != null)
         {
            for each(prereq in prereqs)
            {
               if(!PrerequisiteUtility.isPrerequisiteMet(prereq))
               {
                  validMapTrigger = false;
                  break;
               }
            }
         }
         return validMapTrigger;
      }
      
      private function setMapTriggerPosition(mapTrigger:MapTrigger, xPercent:Number, yPercent:Number, xOffset:Number, yOffset:Number) : void
      {
         var xPercentOffset:Number = NaN;
         var yPercentOffset:Number = NaN;
         var calcX:Number = 0;
         var calcY:Number = 0;
         var modifiedXPosition:Boolean = false;
         var modifiedYPosition:Boolean = false;
         if(mapTrigger != null && Boolean(mapTrigger.getItem()))
         {
            calcX -= mapTrigger.getItem().sizeX >> 1;
            calcY -= mapTrigger.getItem().sizeY >> 1;
         }
         if(!isNaN(xPercent))
         {
            xPercentOffset = Math.floor(xPercent / 100 * mapTrigger.getOuter().getGridWidth());
            if(!isNaN(xPercentOffset))
            {
               calcX += xPercentOffset;
               modifiedXPosition = true;
            }
         }
         if(!isNaN(yPercent))
         {
            yPercentOffset = Math.floor(yPercent / 100 * mapTrigger.getOuter().getGridHeight());
            if(!isNaN(yPercentOffset))
            {
               calcY += yPercentOffset;
               modifiedYPosition = true;
            }
         }
         if(!isNaN(xOffset))
         {
            calcX += xOffset;
            modifiedXPosition = true;
         }
         if(!isNaN(yOffset))
         {
            calcY += yOffset;
            modifiedYPosition = true;
         }
         var oldPosition:Vector3 = mapTrigger.getReference().getPosition();
         if(modifiedXPosition && modifiedYPosition)
         {
            mapTrigger.getReference().setPosition(calcX,calcY,oldPosition.z);
         }
         else if(modifiedXPosition)
         {
            mapTrigger.getReference().setPosition(calcX,oldPosition.y,oldPosition.z);
         }
         else if(modifiedYPosition)
         {
            mapTrigger.getReference().setPosition(oldPosition.x,calcY,oldPosition.z);
         }
      }
   }
}

