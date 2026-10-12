package Widgets.Frames
{
   import Classes.ZItem.FarmItem;
   import Managers.PetAcademyManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.PetAcademyProfessionsSlot;
   import Widgets.Windows.PetAcademyMainWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class PetAcademyProfessionsSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      protected var m_owner:PetAcademyMainWindow;
      
      private var m_close_bt:FarmButton;
      
      private var m_bonus_mc:MovieClip;
      
      private var m_bonusCheckMark:MovieClip;
      
      private var m_bonusItemName:ZwTextField;
      
      private var m_bonusAnimalIcon:FarmIcon;
      
      private var m_animalCategory:String;
      
      private var m_message_tf:ZwTextField;
      
      private var m_frameTitle_tf:ZwTextField;
      
      private var m_buyall_bt:FarmAnimatedCashButton;
      
      private var professional_slot:* = PetAcademyProfessionsSlot;
      
      public function PetAcademyProfessionsSlotContainerFrame(element:DisplayObject, owner:PetAcademyMainWindow)
      {
         this.m_owner = owner;
         super(element);
         if(m_element.hasOwnProperty("close_bt"))
         {
            this.m_close_bt = addWidget(new FarmButton(m_element.close_bt,this.onHide),true) as FarmButton;
         }
         if(m_element.hasOwnProperty("buyall_bt"))
         {
            addWidget(this.m_buyall_bt = new FarmAnimatedCashButton(m_element["buyall_bt"],"Unlock All","0",this.onBuyanimalsCallback) as FarmAnimatedCashButton);
            this.m_buyall_bt.visible = false;
         }
         if(m_element.hasOwnProperty("bonus_mc"))
         {
            this.m_bonus_mc = m_element["bonus_mc"] as MovieClip;
            this.m_bonus_mc.visible = true;
            this.m_bonusCheckMark = this.m_bonus_mc["checkmark_mc"] as MovieClip;
            this.m_bonusCheckMark.visible = false;
            addWidget(this.m_bonusItemName = new ZwTextField(this.m_bonus_mc.itemName_tf,"Bonus Animal Name"));
            this.m_bonusItemName.visible = true;
            if(this.m_bonus_mc.hasOwnProperty("icon_mc"))
            {
               addWidget(this.m_bonusAnimalIcon = new FarmIcon(this.m_bonus_mc.icon_mc));
               this.m_bonusAnimalIcon.visible = true;
            }
         }
         if(m_element.hasOwnProperty("animalName_tf"))
         {
            addWidget(this.m_frameTitle_tf = new ZwTextField(m_element.animalName_tf,""));
         }
         if(m_element.hasOwnProperty("message_tf"))
         {
            addWidget(this.m_message_tf = new ZwTextField(m_element.message_tf,"Collect all the professionals to get the bonus reward!"));
         }
      }
      
      public function onHide(event:Event) : void
      {
         m_element.visible = false;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new PetAcademyProfessionsSlot(slotElement,this.m_owner);
      }
      
      override protected function setupData() : void
      {
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         refresh();
      }
      
      public function set checkBuyAllButton(animalName:String) : void
      {
         animalName = this.m_animalCategory;
         this.m_buyall_bt.setAmountText(this.manager.getBuyAllAverage(animalName).toString());
         if(this.manager.getBuyAllAverage(animalName) > 0 && this.manager.countLockedProfessions(animalName) > 1)
         {
            this.m_buyall_bt.enabled = true;
         }
         else
         {
            this.m_buyall_bt.setAmountText("0");
            this.m_buyall_bt.enabled = false;
         }
      }
      
      public function set animal(animalName:String) : void
      {
         var bonusAnimalName:String = null;
         var bonusItem:FarmItem = null;
         var slotIndex:int = 0;
         this.m_animalCategory = animalName;
         this.checkBuyAllButton = animalName;
         if(this.m_animalCategory != null && this.m_animalCategory != "")
         {
            bonusAnimalName = PetAcademyManager.getInstance().getBonusReward(this.m_animalCategory);
            bonusItem = Global.farmGameSettingsManager.getFarmItemByName(bonusAnimalName);
            slotIndex = this.manager.getSlotIndexforAnimal(this.m_animalCategory);
            this.m_frameTitle_tf.text = this.m_owner.getFrameTitle(slotIndex);
            this.m_message_tf.visible = true;
            if(bonusItem)
            {
               this.m_bonusAnimalIcon.loadIcon(bonusItem.iconUrl);
               this.m_bonusItemName.text = bonusItem.friendlyTitle;
               this.m_bonusCheckMark.visible = this.manager.isAllProfessionCompletedForAnimal(this.m_animalCategory);
            }
         }
      }
      
      private function get manager() : PetAcademyManager
      {
         return PetAcademyManager.getInstance();
      }
      
      private function onBuyanimalsCallback(event:MouseEvent) : void
      {
         this.m_owner.getSlotIndexFromFrame(this.m_animalCategory,event);
         this.m_buyall_bt.enabled = false;
      }
   }
}

