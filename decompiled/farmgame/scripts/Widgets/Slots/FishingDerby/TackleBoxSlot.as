package Widgets.Slots.FishingDerby
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FishingDerbyManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FishingDerby.FishingDerbyStoreWindow;
   import Widgets.Windows.FishingDerby.TackleBoxWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class TackleBoxSlot extends ZwSlotFrame
   {
      
      private var m_itemIcon:FarmIcon;
      
      private var m_count:ZwTextField;
      
      private var m_itemName:ZwTextField;
      
      private var m_equipButton:FarmAnimatedTextButton;
      
      private var m_useButton:FarmAnimatedTextButton;
      
      private var m_buyButton:FarmAnimatedTextButton;
      
      private var m_farmItem:FarmItem;
      
      private var m_parentWindow:TackleBoxWindow;
      
      private var m_slotType:String;
      
      private var m_activeBackground:ZwBaseWidget;
      
      private var m_questionMark:FarmButton;
      
      public function TackleBoxSlot(element:DisplayObject, parentWindow:TackleBoxWindow)
      {
         this.m_parentWindow = parentWindow;
         super(element);
         addWidget(this.m_itemIcon = new FarmIcon(m_element.icon_mc));
         addWidget(this.m_itemName = new ZwTextField(m_element.itemTitle_tf));
         addWidget(this.m_count = new ZwTextField(m_element.itemAmount_tf));
         addWidget(this.m_useButton = new FarmAnimatedTextButton(m_element.use_mat_bt,ZLocUtils.t_pk("Dialogs","Use"),this.equipItem));
         addWidget(this.m_buyButton = new FarmAnimatedTextButton(m_element.buy_bt,ZLocUtils.t_pk("Dialogs","BuyMore"),this.equipItem));
         addWidget(this.m_activeBackground = new ZwBaseWidget(m_element.slotbgOn_mc));
         if(m_element.hasOwnProperty("question_bt"))
         {
            addWidget(this.m_questionMark = new FarmButton(m_element.question_bt));
         }
      }
      
      override public function populate(data:Object) : void
      {
         var description:String = null;
         if(data != null && data.hasOwnProperty("name") && data.hasOwnProperty("type"))
         {
            this.m_slotType = data.type;
            this.m_farmItem = Global.farmGameSettingsManager.getFarmItemByName(data.name);
            if(this.isActive())
            {
               this.m_activeBackground.visible = true;
            }
            else
            {
               this.m_activeBackground.visible = false;
            }
            description = ZLocUtils.t_pk("Items",this.m_farmItem.name + "_message_tooltip");
            if(description != null)
            {
               if(this.m_questionMark)
               {
                  this.m_questionMark.visible = true;
                  this.m_questionMark.detachTooltip();
                  this.m_questionMark.attachTooltip(new FarmTextTooltip(description));
               }
            }
            this.m_itemIcon.loadIcon(this.m_farmItem.icon);
            this.m_itemIcon.visible = true;
            this.m_itemName.text = ZLocUtils.tk_pk_asTitle(this.m_farmItem.friendlyName);
            this.m_itemName.visible = true;
            this.m_itemIcon.alpha = 1;
            if(data.hasOwnProperty("count"))
            {
               this.m_count.text = "x" + data.count;
               this.m_count.visible = true;
               if(data.count <= 0)
               {
                  this.m_itemIcon.alpha = 1;
               }
            }
            if(data.hasOwnProperty("timestamp"))
            {
            }
            switch(data.type)
            {
               case "bait":
                  if(this.m_slotType == "bait")
                  {
                     if(data.count > 0)
                     {
                        this.m_useButton.visible = true;
                        this.m_buyButton.visible = false;
                        this.m_buyButton.callback = this.equipItem;
                        if(this.isActive())
                        {
                           this.m_useButton.enabled = false;
                           this.m_useButton.text = ZLocUtils.t_pk("Dialogs","TackleBoxWindow_Equipped");
                        }
                        else
                        {
                           this.m_useButton.enabled = true;
                           this.m_useButton.text = ZLocUtils.t_pk("Dialogs","Use");
                        }
                     }
                     else
                     {
                        this.m_useButton.visible = false;
                        this.m_buyButton.visible = true;
                        this.m_buyButton.callback = this.buyMore;
                        this.m_buyButton.text = ZLocUtils.t_pk("Dialogs","BuyMore");
                        if(this.isActive())
                        {
                           this.m_buyButton.enabled = false;
                           this.m_buyButton.text = ZLocUtils.t_pk("Dialogs","TackleBoxWindow_Equipped");
                        }
                        else
                        {
                           this.m_buyButton.enabled = true;
                        }
                     }
                  }
                  break;
               case "rod":
                  this.m_buyButton.text = ZLocUtils.t_pk("Dialogs","TackleBoxWindow_Equip");
                  this.m_buyButton.callback = this.equipItem;
                  this.m_useButton.visible = false;
                  this.m_buyButton.visible = true;
                  if(this.isActive())
                  {
                     this.m_buyButton.enabled = false;
                     this.m_buyButton.text = ZLocUtils.t_pk("Dialogs","TackleBoxWindow_Equipped");
                  }
                  else
                  {
                     this.m_buyButton.enabled = true;
                  }
                  break;
               case "buff":
                  if(data.count > 0)
                  {
                     this.m_useButton.visible = true;
                     this.m_buyButton.visible = false;
                     this.m_buyButton.callback = this.equipItem;
                     if(this.isActive())
                     {
                        this.m_useButton.enabled = true;
                        this.m_useButton.text = ZLocUtils.t_pk("Dialogs","Unequip");
                        this.m_useButton.callback = this.unEquipBuff;
                     }
                     else
                     {
                        this.m_useButton.enabled = true;
                        this.m_useButton.text = ZLocUtils.t_pk("Dialogs","Use");
                        this.m_useButton.callback = this.equipItem;
                     }
                  }
                  else
                  {
                     this.m_useButton.visible = false;
                     this.m_buyButton.visible = true;
                     this.m_buyButton.callback = this.buyMore;
                     this.m_buyButton.text = ZLocUtils.t_pk("Dialogs","BuyMore");
                     this.m_buyButton.enabled = true;
                  }
            }
         }
      }
      
      private function isActive() : Boolean
      {
         var fishingInventory:Object = null;
         var fishingBaits:Object = null;
         var fishingBuffs:Object = null;
         var result:Boolean = false;
         switch(this.m_slotType)
         {
            case "rod":
               fishingInventory = FishingDerbyManager.getFishingInventory();
               if(fishingInventory.rod == this.m_farmItem.name)
               {
                  result = true;
               }
               break;
            case "bait":
               fishingBaits = FishingDerbyManager.getFishingBaits();
               if(fishingBaits.active == this.m_farmItem.name)
               {
                  result = true;
               }
               break;
            case "buff":
               fishingBuffs = FishingDerbyManager.getFishingBuffs();
               if(fishingBuffs.active == this.m_farmItem.name)
               {
                  result = true;
               }
         }
         return result;
      }
      
      private function equipItem(event:Event) : void
      {
         switch(this.m_slotType)
         {
            case "rod":
               FishingDerbyManager.instance.equipRod(this.m_farmItem.name);
               break;
            case "bait":
               FishingDerbyManager.instance.equipBait(this.m_farmItem.name);
               break;
            case "buff":
               FishingDerbyManager.instance.equipBuff(this.m_farmItem.name,false);
         }
         this.m_parentWindow.updatePreviewSlots();
      }
      
      private function unEquipBuff(event:Event) : void
      {
         FishingDerbyManager.instance.equipBuff("none",false);
         this.m_parentWindow.updatePreviewSlots();
      }
      
      private function buyMore(event:Event) : void
      {
         this.m_parentWindow.close();
         var defaultTab:String = FishingDerbyStoreWindow.TAB_BAITS;
         switch(this.m_slotType)
         {
            case "rod":
               defaultTab = FishingDerbyStoreWindow.TAB_RODS;
               break;
            case "bait":
               defaultTab = FishingDerbyStoreWindow.TAB_BAITS;
               break;
            case "buff":
               defaultTab = FishingDerbyStoreWindow.TAB_BUFF;
         }
         var baitShopArray:Array = Global.world.getObjectsByCode("1lB");
         if(baitShopArray.length > 0)
         {
            UI.displayPopup(new FishingDerbyStoreWindow(baitShopArray[0],defaultTab),true,"FishingDerbyStoreWindow",true);
         }
      }
   }
}

