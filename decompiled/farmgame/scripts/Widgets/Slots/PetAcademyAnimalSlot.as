package Widgets.Slots
{
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.PetAcademyManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.PetAcademyMainWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class PetAcademyAnimalSlot extends ZwSlotFrame
   {
      
      protected var m_owner:PetAcademyMainWindow;
      
      private var m_viewButton:FarmAnimatedTextButton = null;
      
      private var m_rubiesCountTxt:ZwTextField;
      
      protected var m_data:Object;
      
      private var m_keyBoxClickView:ZwWidget;
      
      private var m_progressBarMc:ZwWidget;
      
      private var m_checkMark:ZwWidget;
      
      private var m_slotIndex:int;
      
      private var m_buy_bt:FarmAnimatedCashButton;
      
      private var m_animalPrice:int = 0;
      
      private var m_animalName:String;
      
      private var m_itemName:ZwTextField;
      
      public function PetAcademyAnimalSlot(element:DisplayObject, owner:PetAcademyMainWindow)
      {
         super(element);
         this.m_owner = owner;
         if(m_element.hasOwnProperty("view_bt"))
         {
            addWidget(this.m_viewButton = new FarmAnimatedTextButton(m_element.view_bt,"Enroll",this.onViewButtonClicked) as FarmAnimatedTextButton);
            this.m_viewButton.visible = false;
         }
         if(m_element.hasOwnProperty("name_tf"))
         {
            addWidget(this.m_itemName = new ZwTextField(m_element.name_tf,"Slot Name"));
         }
         if(m_element.hasOwnProperty("buy_bt"))
         {
            addWidget(this.m_buy_bt = new FarmAnimatedCashButton(m_element["buy_bt"],"Unlock","0",this.onBuyanimalCallback) as FarmAnimatedCashButton);
            this.m_buy_bt.visible = false;
         }
         if(m_element.hasOwnProperty("progressBar_mc"))
         {
            this.m_progressBarMc = addWidget(new ZwWidget(m_element.progressBar_mc),true) as ZwWidget;
         }
      }
      
      private function onBuyanimalCallback(event:MouseEvent) : void
      {
         UI.displayMessage("Do you want to spend " + this.m_animalPrice.toString() + " Farm Cash to unlock this course?",GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyanimalAccept,"",true);
      }
      
      private function onBuyanimalAccept(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            if(PetAcademyManager.getInstance().canBuyAnimal(this.m_slotIndex))
            {
               PetAcademyManager.getInstance().buyAnimal(this.m_slotIndex);
               this.updateAfterBuyAnimal();
            }
         }
      }
      
      public function onViewButtonClicked(event:Event = null) : void
      {
         this.m_owner.populateProfessionsSlots(this.m_slotIndex);
      }
      
      override public function populate(data:Object) : void
      {
         var numProfessionOwned:int = 0;
         super.populate(data);
         this.m_data = data;
         this.m_animalPrice = this.m_data.price;
         this.m_animalName = this.m_data.animalName;
         this.m_itemName.visible = true;
         var isUnlocked:Boolean = PetAcademyManager.getInstance().isAnimalUnlocked(this.m_animalName);
         this.m_slotIndex = this.m_data.slotIndex;
         this.m_itemName.text = this.m_data.slotName;
         if(Boolean(this.m_viewButton) && (this.m_animalPrice == 0 || isUnlocked))
         {
            this.m_viewButton.visible = true;
            if(this.m_buy_bt)
            {
               this.m_buy_bt.visible = false;
            }
         }
         if(this.m_animalPrice > 0 && !isUnlocked)
         {
            if(this.m_buy_bt)
            {
               this.m_buy_bt.visible = true;
            }
            if(this.m_buy_bt)
            {
               this.m_buy_bt.setAmountText(this.m_animalPrice.toString());
            }
            this.m_viewButton.visible = false;
         }
         if(this.m_progressBarMc)
         {
            this.m_progressBarMc.visible = true;
            numProfessionOwned = PetAcademyManager.getInstance().professionProgressForAnimal(this.m_animalName);
            switch(numProfessionOwned)
            {
               case 1:
                  this.m_progressBarMc.element.gotoAndPlay(2);
                  break;
               case 2:
                  this.m_progressBarMc.element.gotoAndPlay(16);
                  break;
               case 3:
                  this.m_progressBarMc.element.gotoAndPlay(31);
                  break;
               case 4:
                  this.m_progressBarMc.element.gotoAndPlay(46);
                  break;
               case 5:
                  this.m_progressBarMc.element.gotoAndPlay(61);
                  break;
               case 6:
                  this.m_progressBarMc.element.gotoAndPlay(61);
            }
         }
      }
      
      private function updateAfterBuyAnimal() : void
      {
         if(this.m_buy_bt)
         {
            this.m_buy_bt.visible = false;
         }
         this.m_viewButton.visible = true;
      }
      
      override public function release() : void
      {
         this.m_viewButton.detachTooltip();
         this.m_viewButton = null;
         this.m_keyBoxClickView = null;
         this.m_rubiesCountTxt = null;
         super.release();
      }
   }
}

