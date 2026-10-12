package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.PetAcademyManager;
   import Managers.WanderingPirateManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.PetAcademyMainWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class PetAcademyProfessionsSlot extends ZwSlotFrame
   {
      
      protected var m_owner:PetAcademyMainWindow;
      
      private var m_data:Object;
      
      private var m_featureName:String;
      
      private var m_itemName:ZwTextField;
      
      private var m_selectBt:FarmAnimatedTextButton;
      
      private var m_animalIcon:FarmIcon;
      
      private var m_locked_mc:MovieClip;
      
      private var m_completeIcon_mc:MovieClip;
      
      private var m_slotIndex:int;
      
      private var m_animalName:String;
      
      private var m_professionName:String;
      
      private var m_buy_bt:FarmAnimatedCashButton;
      
      private var m_animalCost:int;
      
      private var m_average_buyall:int;
      
      public function PetAcademyProfessionsSlot(element:DisplayObject, owner:PetAcademyMainWindow)
      {
         super(element);
         this.m_owner = owner;
         m_element.visible = true;
         this.m_featureName = WanderingPirateManager.FEATURE_NAME;
         if(m_element.hasOwnProperty("itemName_tf"))
         {
            addWidget(this.m_itemName = new ZwTextField(m_element.itemName_tf,"Animal Name"));
         }
         if(m_element.hasOwnProperty("select_bt"))
         {
            addWidget(this.m_selectBt = new FarmAnimatedTextButton(m_element.select_bt,"Take Exam",this.onSelectedProfessionCallback));
            this.m_selectBt.visible = false;
         }
         if(m_element.hasOwnProperty("buy_bt"))
         {
            addWidget(this.m_buy_bt = new FarmAnimatedCashButton(m_element["buy_bt"],"Unlock","0",this.onBuyanimalCallback) as FarmAnimatedCashButton);
            this.m_buy_bt.visible = false;
         }
         if(m_element.hasOwnProperty("icon_mc"))
         {
            addWidget(this.m_animalIcon = new FarmIcon(m_element.icon_mc));
         }
         if(m_element.hasOwnProperty("locked_mc"))
         {
            this.m_locked_mc = m_element.locked_mc as MovieClip;
            this.m_locked_mc.visible = true;
         }
         if(m_element.hasOwnProperty("completeIcon_mc"))
         {
            this.m_completeIcon_mc = m_element.completeIcon_mc as MovieClip;
            this.m_completeIcon_mc.visible = false;
         }
      }
      
      private function onSelectedProfessionCallback(event:MouseEvent) : void
      {
         if(this.m_owner)
         {
            this.m_owner.tintWindow();
            this.m_owner.enableInput = false;
         }
         UI.displayMessage("Are you sure you want to take an exam for this profession? You will not be able to choose another professional until the exam is complete!",GenericPopup.TYPE_YESNO,this.onSelectButtonClicked,"",true);
      }
      
      public function onSelectButtonClicked(event:GenericPopupEvent = null) : void
      {
         if(event.button == GenericPopup.YES)
         {
            PetAcademyManager.getInstance().initializeExam(this.m_animalName,this.m_professionName);
            this.m_owner.close();
            PetAcademyManager.getInstance().showExamUI(event);
            FarmStatsManager.count("animal_academy","profession_start",this.m_professionName,this.m_animalName);
         }
         if(this.m_owner)
         {
            this.m_owner.untintWindow();
            this.m_owner.enableInput = true;
         }
      }
      
      override public function populate(data:Object) : void
      {
         var item:FarmItem = null;
         var slotIcon:String = null;
         super.populate(data);
         this.m_data = data;
         this.m_itemName.visible = true;
         this.m_selectBt.visible = true;
         this.m_animalIcon.visible = true;
         this.m_buy_bt.visible = true;
         this.m_slotIndex = this.m_data.slotIndex;
         this.m_animalName = this.m_data.animalName;
         this.m_professionName = this.m_data.professionName;
         this.m_animalCost = this.m_data.cost;
         var isUnlocked:Boolean = PetAcademyManager.getInstance().isAnimalUnlockedByCost(this.m_professionName);
         var iconName:String = "base0_icon.png";
         if(this.m_animalCost > 0 && isUnlocked)
         {
            this.m_selectBt.visible = false;
            this.m_buy_bt.visible = true;
            this.m_locked_mc.visible = true;
            this.m_buy_bt.setAmountText(this.m_animalCost.toString());
         }
         else
         {
            this.m_selectBt.visible = true;
            this.m_buy_bt.visible = false;
            this.m_locked_mc.visible = false;
            iconName = "base5_icon.png";
         }
         item = Global.farmGameSettingsManager.getFarmItemByName(this.m_professionName);
         slotIcon = item.iconRelativeUrl;
         slotIcon = slotIcon.substr(0,slotIcon.length - 8) + iconName;
         this.m_animalIcon.loadIcon(slotIcon);
         this.m_itemName.text = item.friendlyTitle;
         if(PetAcademyManager.getInstance().hasCompletedProfession(this.m_animalName,this.m_professionName,this.m_slotIndex) == true)
         {
            this.m_locked_mc.visible = false;
            this.m_completeIcon_mc.visible = true;
            iconName = "base5_icon.png";
         }
         else
         {
            this.m_completeIcon_mc.visible = false;
         }
         if(this.m_slotIndex != 0)
         {
            if(PetAcademyManager.getInstance().hasCompletedProfession(this.m_animalName,PetAcademyManager.getInstance().getProfessionForSlot(this.m_animalName,this.m_slotIndex - 1),this.m_slotIndex - 1) == true)
            {
               this.m_locked_mc.visible = false;
               iconName = "base5_icon.png";
            }
         }
         else
         {
            this.m_locked_mc.visible = false;
            iconName = "base5_icon.png";
         }
         item = Global.farmGameSettingsManager.getFarmItemByName(this.m_professionName);
         slotIcon = item.iconRelativeUrl;
         slotIcon = slotIcon.substr(0,slotIcon.length - 8) + iconName;
         this.m_animalIcon.loadIcon(slotIcon);
         this.m_itemName.text = item.friendlyTitle;
         if(PetAcademyManager.getInstance().isAnyExamActive() == true)
         {
            this.m_selectBt.callback = null;
            FarmGameUtil.disableButtonAndShowTooltip(this.m_selectBt,"Complete the active exam first!");
         }
         else
         {
            this.m_selectBt.enabled = true;
            this.m_selectBt.callback = this.onSelectedProfessionCallback;
         }
      }
      
      private function onBuyanimalCallback(event:MouseEvent) : void
      {
         UI.displayMessage("Do you want to spend " + this.m_animalCost + " Farm Cash to unlock this animal set??",GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyanimalAccept,"",true);
      }
      
      private function onBuyanimalAccept(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            PetAcademyManager.getInstance().buyAnimalByCost(this.m_animalCost,this.m_professionName);
            this.updateAfterBuyAnimal();
         }
      }
      
      private function updateAfterBuyAnimal() : void
      {
         if(this.m_buy_bt)
         {
            this.m_buy_bt.visible = false;
         }
         if(this.m_locked_mc)
         {
            this.m_locked_mc.visible = false;
         }
         this.m_selectBt.visible = true;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_professionName);
         var slotIcon:String = item.iconRelativeUrl;
         slotIcon = slotIcon.substr(0,slotIcon.length - 8) + "base5_icon.png";
         this.m_animalIcon.loadIcon(slotIcon);
         this.m_itemName.text = item.friendlyTitle;
         this.m_owner.checkBuyAll();
      }
      
      override public function release() : void
      {
         this.m_animalIcon = null;
         this.m_selectBt = null;
         this.m_completeIcon_mc = null;
         super.release();
      }
   }
}

