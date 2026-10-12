package Display.QueuedIcons
{
   import Classes.Constants.ArrowType;
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Classes.FeatureMessagingDefinition;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Managers.FarmStatsManager;
   import Managers.FeatureCraftingManager;
   import Managers.FeatureMessagingManager;
   import Widgets.Windows.FeatureCrafting.FeatureCraftingContentsWindow;
   import flash.events.Event;
   
   public class FeatureCraftingQueuedIcon extends QueuedIconWithArrow
   {
      
      public static const DEFAULT_ICON_NAME:String = "FeatureCraftingGenericIcon";
      
      private var m_featureName:String;
      
      private var m_featureDefinition:FeatureMessagingDefinition;
      
      public function FeatureCraftingQueuedIcon(xml:XML)
      {
         super(xml);
      }
      
      override public function init() : void
      {
         this.m_featureName = extraData.featureName;
         this.m_featureDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(this.m_featureName);
         if(extraData.removeOnClick)
         {
            removeOnClick = extraData.removeOnClick;
         }
         if(FeatureCraftingManager.instance.initialized)
         {
            this.conditionallyAttachArrow();
         }
         else
         {
            FeatureCraftingManager.instance.addEventListener(FeatureCraftingManager.EVENT_INIT,this.onFeatureCraftingManagerInit);
         }
         FarmStatsManager.count(this.m_featureName,"hud_icon","impressions");
         super.init();
      }
      
      override public function finishClick(parent:DynamicIconQueue) : void
      {
         var system:FeatureCraftingSystem = FeatureCraftingManager.instance.getSystem(this.m_featureName);
         if(system)
         {
            FeatureCraftingContentsWindow.display(system);
         }
         FarmStatsManager.count(this.m_featureName,"hud_icon","clicks");
         super.finishClick(parent);
      }
      
      override public function attachArrow(arrowType:ArrowType, shouldPersistUntilClick:Boolean = false) : void
      {
         switch(arrowType)
         {
            case ArrowType.ARROWNEW:
               setArrowText(ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"HUDIcon_Arrow_RecipeReady"));
         }
         super.attachArrow(arrowType,shouldPersistUntilClick);
      }
      
      private function onFeatureCraftingManagerInit(event:Event) : void
      {
         FeatureCraftingManager.instance.removeEventListener(FeatureCraftingManager.EVENT_INIT,this.onFeatureCraftingManagerInit);
         this.conditionallyAttachArrow();
      }
      
      public function conditionallyAttachArrow() : void
      {
         var system:FeatureCraftingSystem = FeatureCraftingManager.instance.getSystem(this.m_featureName);
         if(Boolean(system) && Boolean(system.getHighestPriorityRecipeThatIsReady()))
         {
            this.attachArrow(ArrowType.ARROWNEW);
         }
      }
   }
}

