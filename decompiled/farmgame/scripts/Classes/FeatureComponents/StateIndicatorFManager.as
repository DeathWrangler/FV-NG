package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import DataSources.BaseDataSource;
   import Events.FarmGameWorldEvent;
   import Managers.FarmGameSettingsManager;
   import Widgets.Windows.StateIndicatorWindow;
   import flash.display.DisplayObject;
   import flash.errors.IllegalOperationError;
   
   public class StateIndicatorFManager extends FeatureManager implements IStateIndicatorComponent
   {
      
      public static const DEFAULT_STATE:String = "default";
      
      public static const EXPAND_STATE:String = "expand";
      
      public static const DEPRECATION_STATE:String = "deprecation";
      
      protected var m_states:Array;
      
      protected var m_hideIndicator:Boolean = false;
      
      protected var m_indicatorCurrentlyHidden:Boolean = true;
      
      protected var m_lookInsideOnClick:Boolean = false;
      
      protected var m_isDelayedShow:Boolean = false;
      
      protected var m_delayedShowState:String = "default";
      
      protected var m_indicator:StateIndicatorWindow = null;
      
      protected var m_canShow:Boolean = true;
      
      protected var m_currentState:String;
      
      private var ClassCompilingArray:Array;
      
      public function StateIndicatorFManager(owner:FeatureBuilding)
      {
         var featureData:BaseDataSource = null;
         var stateDataArray:Array = null;
         var stateData:BaseDataSource = null;
         var featuresXML:XMLList = null;
         var indicatorFeature:XMLList = null;
         var stateItems:XMLList = null;
         var stateItem:XML = null;
         this.m_states = new Array();
         this.ClassCompilingArray = [ArrowIndicatorFManager,AnimalBreedingExpandIndicatorFManager,BreedStateIndicatorFManager,BuildingTooltipFManager,CraftingRecipeReadyIndicatorFManager,CraftingSiloIndicatorFManager,CraftingReadyTooltipFManager,SocialRaffleIndicatorFManager,WishingWellStateIndicatorFManager,IntervalIndicatorFManager,FishermansCoveIndicatorFManager,CarnivalBoothIndicatorManager,GopherGardenIndicatorFManager,GrowableContestArrowIndicatorFManager,OrchardFeatureBuildingExpandIndicatorFManager];
         super(owner);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureData = owner.getFarmItem().getFeatureDataByName(this.featureName);
            if(featureData)
            {
               stateDataArray = featureData.getArray("state");
               if(stateDataArray.length > 0)
               {
                  for each(stateData in stateDataArray)
                  {
                     this.parseState(null,stateData);
                  }
               }
            }
         }
         else
         {
            featuresXML = owner.getFarmItem().getFeaturesXML();
            indicatorFeature = featuresXML.(@name == featureName);
            if(indicatorFeature != null)
            {
               stateItems = indicatorFeature.state;
               if(stateItems != null)
               {
                  for each(stateItem in stateItems)
                  {
                     this.parseState(stateItem);
                  }
               }
            }
         }
      }
      
      protected function parseState(stateItem:XML, stateData:BaseDataSource = null) : void
      {
         throw new IllegalOperationError("StateIndicatorFManager - parseState unimplemented.");
      }
      
      protected function get featureName() : String
      {
         return "";
      }
      
      public function canDisplay() : Boolean
      {
         return this.m_canShow;
      }
      
      public function show(state:String = "default") : void
      {
         if(this.m_states.hasOwnProperty(state))
         {
            this.m_currentState = state;
            if(this.isInWorld() && !this.m_isDelayedShow)
            {
               this.drawIndicator(state,true);
            }
         }
      }
      
      public function update() : void
      {
      }
      
      public function hide() : void
      {
         if(this.m_isDelayedShow)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_CHANGED,this.onDelayedShow);
            this.m_isDelayedShow = false;
         }
         else
         {
            this.removeIndicator();
         }
      }
      
      protected function drawIndicator(state:String = "default", visible:Boolean = true) : void
      {
      }
      
      public function getState(state:String) : Object
      {
         return this.m_states[state];
      }
      
      public function setState(state:String, data:Object) : void
      {
         this.m_states[state] = data;
      }
      
      public function hasState(state:String) : Boolean
      {
         return this.m_states.hasOwnProperty(state);
      }
      
      protected function createIndicator(state:String) : void
      {
      }
      
      public function removeIndicator() : Boolean
      {
         var shouldRedraw:Boolean = false;
         if(Boolean(this.m_indicator) && Boolean(this.m_indicator.visible) && this.m_indicator.parent != null)
         {
            this.m_indicator.visible = false;
            this.m_indicator.parent.removeChild(this.m_indicator);
            this.m_indicator = null;
            this.m_hideIndicator = true;
            shouldRedraw = true;
         }
         this.m_indicatorCurrentlyHidden = true;
         return shouldRedraw;
      }
      
      protected function getHorizontalOffset() : Number
      {
         return 0;
      }
      
      protected function getVerticalOffset() : Number
      {
         return 0;
      }
      
      protected function setIndicatorPosition() : void
      {
         var displayObj:DisplayObject = this.owner.getDisplayObject();
         this.m_indicator.x = displayObj.width * 0.5 + this.getHorizontalOffset();
         this.m_indicator.y = 0 - displayObj.height + this.getVerticalOffset();
      }
      
      public function onClick() : void
      {
      }
      
      public function onMouseOver() : void
      {
      }
      
      public function onMouseOut() : void
      {
      }
      
      public function get lookInsideOnClick() : Boolean
      {
         return this.m_lookInsideOnClick;
      }
      
      public function get indicatorCurrentlyHidden() : Boolean
      {
         return this.m_indicatorCurrentlyHidden;
      }
      
      public function get indicator() : StateIndicatorWindow
      {
         return this.m_indicator;
      }
      
      protected function isInWorld() : Boolean
      {
         return m_owner != null && m_owner.getOuter() != null;
      }
      
      protected function handleDelayedShow(state:String = "default") : void
      {
         this.m_delayedShowState = state;
         if(!this.m_isDelayedShow)
         {
            this.m_isDelayedShow = true;
            Global.world.addEventListener(FarmGameWorldEvent.USER_CHANGED,this.onDelayedShow,false,0,true);
         }
      }
      
      protected function onDelayedShow(event:FarmGameWorldEvent) : void
      {
         Global.world.removeEventListener(FarmGameWorldEvent.USER_CHANGED,this.onDelayedShow);
         this.m_isDelayedShow = false;
         this.show(this.m_delayedShowState);
      }
   }
}

