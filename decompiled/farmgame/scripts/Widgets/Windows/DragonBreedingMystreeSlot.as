package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.DragonBreedingHatcheryManager;
   import Managers.DragonBreedingManager;
   import Managers.IMystreeReskinManager;
   import Managers.MystreeReskinManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Slots.MystreeReskinSlot;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class DragonBreedingMystreeSlot extends MystreeReskinSlot
   {
      
      private var m_parentWindow:IMystreeReskinWindow;
      
      private var m_speedupBtn:FarmAnimatedCashButton;
      
      private const SPEEDUP_BTN:String = "speedup_bt";
      
      private var m_featureName:String;
      
      private var m_managerName:String;
      
      public function DragonBreedingMystreeSlot(element:DisplayObject, featureName:String, managerName:String, window:IMystreeReskinWindow)
      {
         this.m_parentWindow = window;
         this.m_featureName = featureName;
         this.m_managerName = managerName;
         super(element,featureName,window);
         if(m_element.hasOwnProperty(this.SPEEDUP_BTN))
         {
            this.m_speedupBtn = addWidget(new FarmAnimatedCashButton(m_element[this.SPEEDUP_BTN],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"SeedDispenser_SpeedUp"),MystreeReskinManager.getInstance(featureName).getSpeedUpCost().toString(),this.onSpeedUpBtnClicked,false,false,true,ZLocUtils.t("Dialogs","FarmCashBuyConfirmation",{"price":MystreeReskinManager.getInstance(featureName).getSpeedUpCost().toString()}),MystreeReskinManager.getInstance(featureName).getSpeedUpCost()),true) as FarmAnimatedCashButton;
         }
      }
      
      private function onSpeedUpBtnClicked(e:Event) : void
      {
         var levelData:Dictionary = null;
         var bucketNeeded:int = 0;
         if((this.manager as DragonBreedingHatcheryManager).canSpeedUp(m_plotId))
         {
            (this.manager as DragonBreedingHatcheryManager).speedUpSapling(m_plotId);
            refreshSlotData();
            stateTend();
            this.updateLevelText();
            levelData = this.manager.getLevelData(saplingLevel.toString());
            bucketNeeded = levelData.hasOwnProperty("quantity") ? int(parseInt(levelData["quantity"])) : 0;
            if(m_bucketsRequired)
            {
               m_bucketsRequired.text = X + bucketNeeded.toString();
            }
         }
      }
      
      override protected function updateLevelText() : void
      {
         m_levelTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_SlotLevel",{"levelNumber":(saplingLevel - 1).toString()});
      }
      
      override protected function enableSpeedUp(plotId:String = "") : void
      {
         var enable:Boolean = false;
         if((this.manager as DragonBreedingHatcheryManager).isSaplingWaiting(plotId))
         {
            enable = true;
         }
         this.m_speedupBtn.enabled = enable;
         this.m_speedupBtn.visible = enable;
      }
      
      override public function get manager() : IMystreeReskinManager
      {
         return DragonBreedingManager.getHatcheryManager(this.m_managerName);
      }
      
      private function isInTutorial() : Boolean
      {
         var result:Boolean = false;
         if(this.m_parentWindow)
         {
            result = (this.m_parentWindow as DragonBreedingWindow).isInTutorial();
         }
         return result;
      }
      
      override protected function onTendClick(event:Event) : void
      {
         var hasBuckets:Boolean = this.manager.hasSunshineBuckets(m_plotId);
         if(this.isInTutorial())
         {
            this.manager.tendSapling(m_plotId,false);
         }
         else
         {
            this.manager.tendSapling(m_plotId);
         }
         this.enableSpeedUp(m_plotId);
         if(hasBuckets)
         {
            m_window.updateSunshineBuckets();
            super.tendSapling();
         }
         if(this.isInTutorial())
         {
            if((this.m_parentWindow as DragonBreedingWindow).assertTutorialIndexIs(DragonBreedingWindow.TUTORIAL_STEP_7))
            {
               (this.m_parentWindow as DragonBreedingWindow).displayTutorialMessage(DragonBreedingWindow.TUTORIAL_STEP_8);
            }
         }
      }
      
      override protected function onGetMystreeClick(event:Event) : void
      {
         (this.manager as DragonBreedingHatcheryManager).hatchDragonEgg(m_plotId,m_window as DragonBreedingWindow);
      }
      
      override public function release() : void
      {
         if(this.m_speedupBtn)
         {
            this.m_speedupBtn.release();
            this.m_speedupBtn = null;
         }
         super.release();
      }
   }
}

