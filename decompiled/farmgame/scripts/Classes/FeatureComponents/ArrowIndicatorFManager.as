package Classes.FeatureComponents
{
   import Classes.Constants.XMLKeys;
   import Classes.FeatureBuilding;
   import Classes.util.MovieClipUtils;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   import Managers.PerformanceExperimentManager;
   import Widgets.Windows.ArrowIndicatorWindow;
   import flash.display.Sprite;
   
   public class ArrowIndicatorFManager extends StateIndicatorFManager implements IStateIndicatorComponent
   {
      
      protected static const DEFAULT_ARROW_HORIZONTAL_OFFSET:Number = 30;
      
      protected static const DEFAULT_ARROW_VERTICAL_OFFSET:Number = -10;
      
      protected var m_arrowStates:Array = new Array();
      
      protected var m_hideArrow:Boolean = false;
      
      protected var m_arrowCurrentlyHidden:Boolean = true;
      
      private var ClassCompilingArray:Array = [AnimalBreedingExpandIndicatorFManager,BreedStateIndicatorFManager,CraftingRecipeReadyIndicatorFManager,CraftingSiloIndicatorFManager,SocialRaffleIndicatorFManager,WishingWellStateIndicatorFManager,IntervalIndicatorFManager,FishermansCoveIndicatorFManager,CarnivalBoothIndicatorManager,FeatureCraftingIndicatorManager,GopherGardenIndicatorFManager,LootTicketBoothIndicatorManager,UGCDecoWorkshopIndicatorFManager,TutorialArrowIndicatorFManager,OrchardFeatureBuildingExpandIndicatorFManager];
      
      public function ArrowIndicatorFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override protected function parseState(stateItem:XML, stateData:BaseDataSource = null) : void
      {
         var stateName:String = null;
         var title:String = null;
         var desc:String = null;
         var icon:String = null;
         var verticalIndicatorOffset:String = null;
         var horizontalIndicatorOffset:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(stateData)
            {
               stateName = stateData.getString("name");
               title = stateData.getString("title");
               desc = stateData.getString("desc");
               icon = stateData.getString("icon");
               verticalIndicatorOffset = stateData.getString("verticalIndicatorOffset");
               horizontalIndicatorOffset = stateData.getString("horizontalIndicatorOffset");
            }
         }
         else
         {
            stateName = stateItem[XMLKeys.ATTR_NAME];
            title = String(stateItem.title);
            desc = String(stateItem.desc);
            icon = stateItem.icon;
            verticalIndicatorOffset = stateItem.verticalIndicatorOffset;
            horizontalIndicatorOffset = stateItem.horizontalIndicatorOffset;
         }
         var splitTitle:Array = title.split(":",2);
         var splitDesc:Array = desc.split(":",2);
         m_states[stateName] = {
            "title":ZLocUtils.t(splitTitle[0],splitTitle[1]),
            "desc":ZLocUtils.t(splitDesc[0],splitDesc[1]),
            "icon":Global.getAssetURL(icon),
            "verticalIndicatorOffset":verticalIndicatorOffset,
            "horizontalIndicatorOffset":horizontalIndicatorOffset
         };
      }
      
      override protected function get featureName() : String
      {
         return FeatureManager.ARROW_INDICATOR_MENU_FEATURE_NAME;
      }
      
      override protected function drawIndicator(state:String = "default", visible:Boolean = true) : void
      {
         var spr:Sprite = this.owner.getDisplayObject() as Sprite;
         if(canDisplay())
         {
            if(m_indicator == null && spr.numChildren > 0)
            {
               this.createIndicator(state);
            }
            if(m_indicator)
            {
               if(this.m_indicator.parent == null)
               {
                  setIndicatorPosition();
                  spr.addChild(this.m_indicator);
                  m_indicator.visible = visible;
                  if(PerformanceExperimentManager.isInExtremePerformanceLimiterExperiment)
                  {
                     MovieClipUtils.recursiveStop(m_indicator);
                  }
               }
            }
            m_indicatorCurrentlyHidden = !visible;
         }
      }
      
      override protected function createIndicator(state:String) : void
      {
         var arrowState:Object = m_states[state];
         if(arrowState != null)
         {
            m_indicator = new ArrowIndicatorWindow(arrowState.icon,arrowState.title,arrowState.desc,null);
            setIndicatorPosition();
         }
      }
      
      override public function onMouseOver() : void
      {
         var arrowIndicator:ArrowIndicatorWindow = m_indicator as ArrowIndicatorWindow;
         if(arrowIndicator)
         {
            arrowIndicator.showRolloverText(true);
         }
      }
      
      override public function onMouseOut() : void
      {
         var arrowIndicator:ArrowIndicatorWindow = m_indicator as ArrowIndicatorWindow;
         if(arrowIndicator)
         {
            arrowIndicator.showRolloverText(false);
         }
      }
      
      override protected function getHorizontalOffset() : Number
      {
         return DEFAULT_ARROW_HORIZONTAL_OFFSET;
      }
      
      override protected function getVerticalOffset() : Number
      {
         return DEFAULT_ARROW_VERTICAL_OFFSET;
      }
   }
}

