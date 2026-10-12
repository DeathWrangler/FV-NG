package Classes
{
   import Classes.ZItem.DeprecatorSettings;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.GenericDialog;
   import Display.TutorialUI;
   import Managers.OffboardingManager;
   
   public class OrchardConstructionBuilding extends ConstructionBuilding implements IOffboardResource
   {
      
      private var m_repromptDialog:GenericDialog;
      
      protected var m_isDeprecating:Boolean;
      
      private var m_isDeprecationChecked:Boolean = false;
      
      public function OrchardConstructionBuilding(buildingType:String = null)
      {
         super(buildingType);
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         if(!this.m_isDeprecationChecked)
         {
            this.m_isDeprecationChecked = true;
            if(this.needsOffBoardingAndReplacement())
            {
               this.m_isDeprecating = true;
               OffboardingManager.handleOffBoarding(this,false,true);
            }
         }
      }
      
      override public function transformBuilding(resultData:Object = null) : MapResource
      {
         return super.transformBuilding(resultData);
      }
      
      override public function onObjectDrop() : void
      {
         var buildingName:String = null;
         super.onObjectDrop();
         var prefix:String = "Orchard";
         if(m_buildingName != "" && ZLocUtils.hasString("Dialogs",m_buildingName + "Tutorial_Title"))
         {
            prefix = m_buildingName;
         }
         else
         {
            buildingName = TutorialUI.getFinishedBuildingName(this);
            if(buildingName != "" && ZLocUtils.hasString("Dialogs",buildingName + "Tutorial_Title"))
            {
               prefix = buildingName;
            }
         }
         var seenFlag:String = prefix + "Tutorial";
         if(!Global.player.getSeenFlag(seenFlag))
         {
            Global.player.setSeenFlag(seenFlag);
            TutorialUI.displayOrchardsTutorialWindow(this);
         }
      }
      
      override public function shouldCopyStorageWhenReplacing() : Boolean
      {
         return true;
      }
      
      public function needsOffBoardingAndReplacement() : Boolean
      {
         var deprecator:DeprecatorSettings = null;
         var result:Boolean = false;
         if(!this.m_isDeprecating && state != STATE_PREVIEW)
         {
            deprecator = Global.farmGameSettingsManager.getDeprecatorSettings(this.getItemName());
            if(deprecator)
            {
               result = Boolean(deprecator) && deprecator.checkPrereqs();
            }
         }
         return result;
      }
      
      public function getOffboardingReplacementResource() : MapResource
      {
         return OffboardingManager.getOffboardingReplacementResource(this);
      }
   }
}

