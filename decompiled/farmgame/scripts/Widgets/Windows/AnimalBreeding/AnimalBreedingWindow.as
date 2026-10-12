package Widgets.Windows.AnimalBreeding
{
   import Classes.FeatureBuilding;
   import Classes.breeding.AnimalBreedingSession;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Display.UI;
   import Managers.breeding.AnimalBreedingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import Widgets.Frames.Breeding.BreedingCollectionFrame;
   import Widgets.Frames.Breeding.BreedingFixedMatingFrame;
   import Widgets.Frames.Breeding.BreedingProgressFrame;
   import Widgets.Frames.Breeding.BreedingRenderFrame;
   import Widgets.Frames.GenericExpandSlotFrame;
   import Widgets.Windows.Breeding.BreedingWindow;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   
   public class AnimalBreedingWindow extends BreedingWindow
   {
      
      public static const ASSET_PATH:String = "assets/dialogs/FV_TurtleBreeding.swf";
      
      private static var m_classCompilingArray:Array = [BreedingRenderFrame,BreedingProgressFrame,GenericExpandSlotFrame,BreedingCollectionFrame];
      
      public function AnimalBreedingWindow(building:FeatureBuilding)
      {
         super(building,ASSET_PATH,building.getItemName());
      }
      
      override protected function setUpMatingWindow() : void
      {
         m_penMatingFrame = new BreedingFixedMatingFrame(m_window.frame_inventory_mc.breed_mc,this);
         addWidget(m_penMatingFrame,false);
      }
      
      override protected function showOnboardingDialogs() : void
      {
         if(Global.animalBreedingSettings.getFeatureConfigAttr(building.getItem().name,"fixedOutcome") != null && Global.animalBreedingSettings.getFeatureConfigAttr(building.getItem().name,"fixedOutcome") == true)
         {
            super.showOnboardingDialogs();
         }
      }
      
      override protected function setupTabFrames() : void
      {
         var tabsConfig:Array = null;
         var i:int = 0;
         var button:FarmAnimatedTextButton = null;
         var frameClassName:String = null;
         var frameClass:Class = null;
         var frame:* = undefined;
         tabsConfig = Global.animalBreedingSettings.getDialogConfig(m_building.getItem().name);
         m_toggleManager = new ZwToggleManager();
         for(i = 0; i < tabsConfig.length; i++)
         {
            if(!(m_window["generic" + i + "_bt"] != null && m_window[tabsConfig[i].elementName] != null))
            {
               continue;
            }
            button = new FarmAnimatedTextButton(m_window["generic" + i + "_bt"],ZLocUtils.t("Dialogs",m_featureName + "_" + tabsConfig[i].name),null);
            addWidget(button);
            frameClassName = tabsConfig[i].className;
            frameClass = getDefinitionByName(frameClassName) as Class;
            switch(tabsConfig[i].name)
            {
               case "Inventory":
                  m_renderFrame = new frameClass(m_window[tabsConfig[i].elementName],this);
                  addWidget(m_renderFrame);
                  m_toggleManager.addToggle(new ZwVisibilityToggle(button,m_renderFrame),true);
                  break;
               case "Collections":
                  frame = new frameClass(m_window[tabsConfig[i].elementName],this);
                  addWidget(frame as ZwFrame,false);
                  m_toggleManager.addToggle(new ZwVisibilityToggle(button,frame as ZwFrame));
                  break;
               case "Progress":
                  m_penProgressFrame = new frameClass(m_window[tabsConfig[i].elementName],m_skillState);
                  addWidget(m_penProgressFrame,false);
                  m_toggleManager.addToggle(new ZwVisibilityToggle(button,m_penProgressFrame));
                  break;
               case "Expansion":
                  m_expandFrame = new frameClass(m_window[tabsConfig[i].elementName],getExpansionData(),this,this.m_building,m_building.expand);
                  m_expandFrame.setItemData(getExpansionData());
                  addWidget(m_expandFrame,false);
                  m_toggleManager.addToggle(new ZwVisibilityToggle(button,m_expandFrame,onClickExpand));
            }
         }
      }
      
      override public function displayMatingWindow(breedingSession:AnimalBreedingSession) : void
      {
         var maxLimit:Number = NaN;
         breedingSession.suiteSlot = AnimalBreedingManager.getInstance().findFreeSlot(breedingSession);
         if(breedingSession.suiteSlot >= 0)
         {
            if(AnimalBreedingManager.getInstance().canBreed(breedingSession.owner,true))
            {
               m_penMatingFrame.loadData(breedingSession);
               m_penMatingFrame.visible = true;
            }
            else
            {
               maxLimit = AnimalBreedingManager.getInstance().getMaxAnimalsCount(m_building.getItemName());
               UI.displayMessage(ZLocUtils.t("Dialogs",m_featureName + "_Reached_Limit",{"quantity":maxLimit}),0,null,"",true);
            }
         }
         else
         {
            UI.displayMessage(ZLocUtils.t("Dialogs",m_featureName + "_No_Free_Slots"),0,null,"",true);
         }
      }
      
      override protected function howDoesThisWorkCallback(event:MouseEvent) : void
      {
         var tutorialFunction:Function = TutorialUI[building.getItemName() + "TutorialWindow"];
         if(tutorialFunction != null)
         {
            tutorialFunction();
         }
      }
   }
}

