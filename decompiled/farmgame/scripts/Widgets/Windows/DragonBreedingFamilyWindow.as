package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.UGC.UGCDragonBreeding;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.DragonBreedingConfigManager;
   import Managers.DragonBreedingManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Frames.DragonBreedingFamilyTreeFrame;
   import Widgets.Frames.DragonBreedingProgressFrame;
   import Widgets.Frames.DragonBreedingSelectDragonFrame;
   import Widgets.TextFields.FarmTextField;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class DragonBreedingFamilyWindow extends FarmWindowWithTutorial
   {
      
      private var m_featureName:String = "";
      
      private var m_selectDragonFrame:DragonBreedingSelectDragonFrame;
      
      private var m_familyTreeFrame:DragonBreedingFamilyTreeFrame;
      
      private var m_progressFrame:DragonBreedingProgressFrame;
      
      private var m_dragon_family:FarmTextField;
      
      private var m_dragon_family_subtitle:FarmTextField;
      
      private var m_whatsthis:FarmAnimatedButton;
      
      private var m_fromSource:int;
      
      private var m_selectionWindow:DragonBreedingSelectionWindow;
      
      private const NO_OF_SCENES:int = 3;
      
      private var m_owner:DragonBreedingWindow;
      
      public var m_close_bt:FarmButton;
      
      public function DragonBreedingFamilyWindow(featureName:String, fromSource:int = 0, selectionWindow:DragonBreedingSelectionWindow = null, owner:DragonBreedingWindow = null)
      {
         this.m_featureName = featureName;
         this.m_fromSource = fromSource;
         this.m_selectionWindow = selectionWindow;
         this.m_owner = owner;
         var dialogPath:String = DragonBreedingManager.getInstance(this.m_featureName).getFamilyTreeDialogURL();
         if(dialogPath == "" || dialogPath == null)
         {
            dialogPath = "assets/dialogs/DragonBreeding/FV_DragonBreeding_PopUps_FamilyTree.swf";
         }
         super(this.m_featureName + "_family",dialogPath,this.NO_OF_SCENES);
      }
      
      private function onHowDoesThisWorkClick(event:Event) : void
      {
         showTutorial();
      }
      
      override protected function onClose(ev:Event) : void
      {
         super.onClose(ev);
         DragonBreedingManager.getInstance(this.m_featureName).selectedOffspring = null;
      }
      
      override public function close() : void
      {
         if(this.m_owner)
         {
            this.m_owner.enableInput = true;
            UI.stopPopups(false);
            this.m_owner.untintWindow();
         }
         super.close();
      }
      
      override protected function afterLoad() : void
      {
         if(m_window.hasOwnProperty("close_bt"))
         {
            if(this.m_fromSource == DragonBreedingManager.MAIN_WINDOW)
            {
               setCloseButtonVisible(true);
            }
            else
            {
               setCloseButtonVisible(false);
            }
         }
      }
      
      public function openSelectionWindow(maleItemName:String, femaleItemName:String) : void
      {
         DragonBreedingManager.getInstance(this.m_featureName).selectedFemaleDragonId = Global.farmGameSettingsManager.getFarmItemCodeByName(femaleItemName);
         DragonBreedingManager.getInstance(this.m_featureName).selectedMaleDragonId = Global.farmGameSettingsManager.getFarmItemCodeByName(maleItemName);
         var offSpringObj:Object = DragonBreedingManager.getInstance(this.m_featureName).selectedOffspring;
         UI.displayPopup(new DragonBreedingSelectionWindow(this.m_featureName,offSpringObj,this.m_owner),false);
         UI.stopPopups(false);
         if(this.m_owner)
         {
            this.m_owner.tintWindow();
            this.m_owner.enableInput = false;
         }
         super.close();
      }
      
      private function runthroughOffsprings() : void
      {
         var offspring:Dictionary = null;
         var dragon:Object = null;
         var dragon2:Object = null;
         var i:int = 0;
         var dragonbreeding:UGCDragonBreeding = null;
         var maleDragons:Object = DragonBreedingManager.getInstance(this.m_featureName).getMutableMaleData();
         var femaleDragons:Object = DragonBreedingManager.getInstance(this.m_featureName).getMutableFemaleData();
         for each(dragon in maleDragons)
         {
            for each(dragon2 in femaleDragons)
            {
               for(i = 1; i <= 16; i++)
               {
                  offspring = DragonBreedingManager.getInstance(this.m_featureName).getOffspringForCouple(dragon.itemName,dragon2.itemName,i.toString()) as Dictionary;
                  if(offspring[DragonBreedingConfigManager.BODY_DATA_KEY])
                  {
                     dragonbreeding = new UGCDragonBreeding(Global.farmGameSettingsManager.getFarmItemNameByCode(offspring[DragonBreedingConfigManager.BODY_DATA_KEY]),offspring);
                     dragonbreeding.createDragon();
                  }
               }
            }
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window)
         {
            if(m_window.hasOwnProperty("selectdragon_mc"))
            {
               this.m_selectDragonFrame = new DragonBreedingSelectDragonFrame(m_window.selectdragon_mc);
            }
            if(m_window.hasOwnProperty("family_mc"))
            {
               this.m_familyTreeFrame = new DragonBreedingFamilyTreeFrame(m_window.family_mc,this,this.m_fromSource,this.m_selectionWindow);
               addWidget(this.m_familyTreeFrame,true);
            }
            if(m_window.hasOwnProperty("progress_mc"))
            {
               this.m_progressFrame = new DragonBreedingProgressFrame(m_window.progress_mc);
            }
            if(m_window.hasOwnProperty("title_tf"))
            {
               this.m_dragon_family = new FarmTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_FamilyWindowTitle"));
               addWidget(this.m_dragon_family,true);
            }
            if(m_window.hasOwnProperty("subtitle_tf"))
            {
               this.m_dragon_family_subtitle = new FarmTextField(m_window.subtitle_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_FamilyWindowSubTitle"));
               addWidget(this.m_dragon_family_subtitle,true);
            }
            if(m_window.hasOwnProperty("whatisthis_mc"))
            {
               this.m_whatsthis = new FarmAnimatedButton(m_window.whatisthis_mc,this.onHowDoesThisWorkClick);
               addWidget(this.m_whatsthis,true);
            }
         }
      }
      
      override protected function release() : void
      {
         super.release();
      }
   }
}

