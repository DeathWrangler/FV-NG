package Classes
{
   import Classes.FeatureComponents.VotingComponent;
   import Classes.FeatureComponents.VotingMapResourceComponent;
   import Classes.ZItem.DeprecatorSettings;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Managers.AntiqueMuseumV2Manager;
   import Managers.FarmStatsManager;
   import Managers.FeatureMessagingManager;
   import Managers.OffboardingManager;
   import flash.events.MouseEvent;
   
   public class AntiqueMuseumV2Deco extends Decoration implements IOffboardResource
   {
      
      private var m_votingComponent:VotingComponent;
      
      private var m_votingMapResourceComponent:VotingMapResourceComponent = null;
      
      private var m_isOffboarded:Boolean = false;
      
      private var m_imageNameMappings:Array = [];
      
      public function AntiqueMuseumV2Deco(itemName:String = null)
      {
         super(itemName);
         this.m_votingComponent = new VotingComponent(this);
         this.m_imageNameMappings = this.buildNameMappings();
         this.m_votingMapResourceComponent = new VotingMapResourceComponent(this,this.m_imageNameMappings);
      }
      
      public function buildNameMappings() : Array
      {
         var path:XML = null;
         var levels:XMLList = null;
         var images:Array = null;
         var element:XML = null;
         var imageNameMappings:Array = [];
         var decorationXml:XML = this.m_votingComponent.getGameSettingsXml();
         if(Boolean(decorationXml) && decorationXml.hasOwnProperty("levelPaths"))
         {
            for each(path in decorationXml["levelPaths"]["path"])
            {
               levels = path.elements("level");
               images = [];
               for each(element in levels)
               {
                  images.push(element.toString());
               }
               imageNameMappings[int(path.@number)] = images;
            }
         }
         return imageNameMappings;
      }
      
      public function needsOffBoardingAndReplacement() : Boolean
      {
         if(this.m_isOffboarded)
         {
            return true;
         }
         var needOffboarding:Boolean = false;
         var deprecator:DeprecatorSettings = Global.farmGameSettingsManager.getDeprecatorSettings(this.getItemName());
         if(Boolean(Global.player.isDataLoaded) && Boolean(deprecator) && deprecator.checkPrereqs())
         {
            needOffboarding = true;
            this.m_isOffboarded = true;
         }
         return needOffboarding;
      }
      
      public function getOffboardingReplacementResource() : MapResource
      {
         var replacementResource:MapResource = null;
         var deprecator:DeprecatorSettings = Global.farmGameSettingsManager.getDeprecatorSettings(this.getItemName());
         var resourceName:String = "";
         var level:String = this.m_votingMapResourceComponent.getCurrentImageName();
         if(deprecator != null)
         {
            resourceName = deprecator.getReplacement(level);
         }
         if(resourceName != "")
         {
            replacementResource = OffboardingManager.createReplacementResource(resourceName);
         }
         return replacementResource;
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         this.m_votingMapResourceComponent.loadObject(data);
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_votingComponent.getFeatureName(),this.m_votingComponent.displayDialog);
      }
      
      override protected function getMenuItems() : Array
      {
         return [{
            "label":ZLocUtils.t("FarmGame","LookInside"),
            "action":LOOK_INSIDE
         },{
            "label":ZLocUtils.t("FarmGame","Move"),
            "action":MOVE_OBJECT
         },{
            "label":ZLocUtils.t("FarmGame","Sell"),
            "action":SELL_OBJECT
         }];
      }
      
      override protected function canShowStoreMenuItem() : Boolean
      {
         return false;
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         this.m_votingMapResourceComponent.onUpdate(delta);
      }
      
      override protected function updateToolTipText() : void
      {
         this.m_votingMapResourceComponent.updateToolTipText();
         this.updateToolTipPosition();
      }
      
      public function hideArrowDisplay() : void
      {
         this.m_votingMapResourceComponent.hideArrowDisplay();
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case LOOK_INSIDE:
                  AntiqueMuseumV2Manager.getInstance(AntiqueMuseumV2Manager.FEATURE_NAME).showMainWindow();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      override public function getCurrentImageName() : String
      {
         if(this.m_imageNameMappings.length == 0)
         {
            this.m_imageNameMappings = this.buildNameMappings();
            this.m_votingMapResourceComponent.imageNameMappings = this.m_imageNameMappings;
         }
         return this.m_votingMapResourceComponent.getCurrentImageName();
      }
      
      override public function onPlacedFirstTime() : void
      {
         FarmStatsManager.count("feature_survey",this.getItemName(),"place_first_time");
         this.m_votingComponent.displayDialog();
      }
      
      override public function onSell() : void
      {
         super.onSell();
         FeatureMessagingManager.getInstance().unregisterFeatureInitialized(this.m_votingComponent.getFeatureName());
      }
      
      override public function onObjectDrop() : void
      {
         super.onObjectDrop();
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_votingComponent.getFeatureName(),this.m_votingComponent.displayDialog);
      }
      
      override public function detach() : void
      {
         if(this.m_votingComponent)
         {
            FeatureMessagingManager.getInstance().unregisterFeatureInitialized(this.m_votingComponent.getFeatureName());
         }
         super.detach();
      }
   }
}

