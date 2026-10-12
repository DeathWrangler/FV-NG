package Classes
{
   import Classes.Managers.HUDTutorialManager;
   import Classes.Tutorial.EventTutState;
   import Classes.Tutorial.FeatureBuildingTutState;
   import Classes.Tutorial.FishingModeTutState;
   import Classes.Tutorial.FourPanelTutorialState;
   import Classes.Tutorial.IHUDTutorialState;
   import Classes.Tutorial.JapanTutWindowState;
   import Classes.Tutorial.NextButtonCenteredWithArrowTutState;
   import Classes.Tutorial.NextButtonTutState;
   import Classes.Tutorial.OpenFeatureBuildingWindowState;
   import Classes.Tutorial.OpenTutWindowState;
   import flash.utils.getDefinitionByName;
   
   public class HUDTutorialStateContainer
   {
      
      public static const CONFIG_KEY:String = "HudTutorials";
      
      private static const FALSE:String = "false";
      
      private var m_featureName:String;
      
      private var m_windowAssetPath:String;
      
      private var m_seenFlag:String;
      
      private var m_stats:Array;
      
      private var m_hasReplay:Boolean;
      
      private var m_isPersistantProgress:Boolean;
      
      private var m_hudIconPath:String;
      
      private var m_XoffSet:int = 0;
      
      private var m_YoffSet:int = 0;
      
      private var m_hudToolTipKey:String;
      
      private var m_hasWindow:Boolean;
      
      private var m_compileArray:Array;
      
      private var m_tutController:HUDTutorialManager;
      
      private var m_currentStateIndex:int;
      
      private var m_hasSkipButton:Boolean;
      
      protected var m_dataTable:Vector.<IHUDTutorialState>;
      
      public function HUDTutorialStateContainer(tutController:HUDTutorialManager, featureName:String)
      {
         var item:XML = null;
         var FTUEList:XMLList = null;
         var statsString:String = null;
         var stateObject:Object = null;
         var itemAtributes:XMLList = null;
         var attribute:XML = null;
         var ftueStepClassName:String = null;
         var ftueStepClass:Class = null;
         var ftueStep:* = undefined;
         var attName:String = null;
         var attValue:String = null;
         var tableLength:int = 0;
         this.m_compileArray = [IHUDTutorialState,FishingModeTutState,NextButtonTutState,FeatureBuildingTutState,EventTutState,OpenTutWindowState,OpenFeatureBuildingWindowState,NextButtonCenteredWithArrowTutState,FourPanelTutorialState,JapanTutWindowState];
         super();
         this.m_featureName = featureName;
         if(tutController)
         {
            this.m_tutController = tutController;
         }
         this.m_currentStateIndex = 0;
         this.m_dataTable = new Vector.<IHUDTutorialState>();
         var ftueConfiguration:Array = new Array();
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(CONFIG_KEY);
         if(featureXML)
         {
            FTUEList = featureXML.ftue;
         }
         var ftue:XML = null;
         var ftueLength:int = FTUEList.length();
         for(var i:int = 0; i < ftueLength; i++)
         {
            ftue = FTUEList[i];
            if(ftue.@name == featureName)
            {
               if(ftue.@skipButton)
               {
                  this.m_hasSkipButton = ftue.@skipButton != FALSE;
               }
               if(ftue.@replay)
               {
                  this.m_hasReplay = ftue.@replay != FALSE;
               }
               if(ftue.@seenFlag)
               {
                  this.m_seenFlag = ftue.@seenFlag;
               }
               if(ftue.hasOwnProperty("@Xoffset"))
               {
                  this.m_XoffSet = ftue.@Xoffset;
               }
               if(ftue.hasOwnProperty("@Yoffset"))
               {
                  this.m_YoffSet = ftue.@Yoffset;
               }
               if(ftue.hasOwnProperty("@hudWindowHidden") && ftue.@hudWindowHidden != FALSE)
               {
                  this.m_hasWindow = false;
               }
               else
               {
                  this.m_hasWindow = true;
               }
               if(ftue.hasOwnProperty("@persistantProgress"))
               {
                  this.m_isPersistantProgress = ftue.@persistantProgress != FALSE;
               }
               if(ftue.@replayHudIconAsset)
               {
                  this.m_hudIconPath = ftue.@replayHudIconAsset;
               }
               if(ftue.@toolTipKey)
               {
                  this.m_hudToolTipKey = ftue.@toolTipKey;
               }
               statsString = ftue.@stats;
               if(statsString)
               {
                  this.m_stats = statsString.split(",");
               }
               this.m_windowAssetPath = ftue.@asset;
               break;
            }
         }
         var stateObjectsXML:XMLList = ftue.item;
         for each(item in stateObjectsXML)
         {
            stateObject = {};
            itemAtributes = item.attributes();
            for each(attribute in itemAtributes)
            {
               attName = attribute.name();
               attValue = attribute.toXMLString();
               stateObject[attName] = attValue;
            }
            ftueStepClassName = stateObject.className as String;
            ftueStepClass = getDefinitionByName("Classes.Tutorial." + ftueStepClassName) as Class;
            ftueStep = new ftueStepClass(stateObject);
            this.m_dataTable.push(ftueStep);
         }
         if(this.m_isPersistantProgress)
         {
            this.m_currentStateIndex = Global.player.getActionCount(this.m_seenFlag);
            tableLength = int(this.m_dataTable.length);
            if(this.m_currentStateIndex >= tableLength && Boolean(Global.flashHotParams["HG_FTUE_EXPLOIT_AS_FIX_FARM_91946"]))
            {
               this.m_currentStateIndex = tableLength - 1;
            }
         }
         else
         {
            Global.player.setActionCount(this.m_seenFlag,this.m_currentStateIndex);
         }
      }
      
      private function initState() : void
      {
         (this.m_dataTable[this.m_currentStateIndex] as IHUDTutorialState).initialize();
      }
      
      public function initialize() : void
      {
         this.initState();
      }
      
      public function release() : void
      {
         if(this.m_dataTable.indexOf(this.m_currentStateIndex) >= 0)
         {
            this.m_dataTable[this.m_currentStateIndex].cleanUp();
         }
         this.m_currentStateIndex = 0;
      }
      
      public function step() : void
      {
         var currentTutStep:IHUDTutorialState = this.m_dataTable[this.m_currentStateIndex];
         if(currentTutStep.isCompleted() && this.m_currentStateIndex < this.m_dataTable.length)
         {
            currentTutStep.cleanUp();
            ++this.m_currentStateIndex;
            if(this.m_isPersistantProgress)
            {
               Global.player.incrementActionCount(this.m_seenFlag,this.m_isPersistantProgress);
            }
            if(this.m_currentStateIndex >= this.m_dataTable.length)
            {
               HUDTutorialManager.instance.stop();
            }
            else
            {
               this.initState();
            }
         }
      }
      
      public function getAssetPath() : String
      {
         return this.m_windowAssetPath;
      }
      
      public function getHasSkipButton() : Boolean
      {
         return this.m_hasSkipButton;
      }
      
      public function getSeenFlag() : String
      {
         return this.m_seenFlag;
      }
      
      public function getXoffSet() : int
      {
         return this.m_XoffSet;
      }
      
      public function getYoffSet() : int
      {
         return this.m_YoffSet;
      }
      
      public function getStatCounters() : Array
      {
         return this.m_stats;
      }
      
      public function getHasReplay() : Boolean
      {
         return this.m_hasReplay;
      }
      
      public function getFeatureName() : String
      {
         return this.m_featureName;
      }
      
      public function getHudIconPath() : String
      {
         return this.m_hudIconPath;
      }
      
      public function getHudToolTipKey() : String
      {
         return this.m_hudToolTipKey;
      }
      
      public function hasWindow() : Boolean
      {
         return this.m_hasWindow;
      }
   }
}

