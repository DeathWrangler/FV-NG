package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.GuildManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.GuildConsumableCraftWindow;
   import Widgets.Windows.GuildMainWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class GuildConsumableCraftSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 100;
      
      private static const ICON_REQ_SIZE:int = 50;
      
      private var m_featureName:String;
      
      protected var m_data:Object;
      
      private var m_consumableIcon:FarmIcon;
      
      private var m_consumableFarmItem:FarmItem;
      
      private var m_index:int;
      
      private var m_countTf:ZwTextField;
      
      private var m_makeBt:FarmAnimatedTextButton;
      
      private var m_buyBt:FarmAnimatedCashButton;
      
      private var m_req0_mc:MovieClip;
      
      private var m_req1_mc:MovieClip;
      
      private var m_req2_mc:MovieClip;
      
      private var m_count0Tf:ZwTextField;
      
      private var m_count1Tf:ZwTextField;
      
      private var m_count2Tf:ZwTextField;
      
      public var m_pkgName:String;
      
      public var m_pkgItem:FarmItem;
      
      public var m_pkgReq:int;
      
      private var m_owner:GuildConsumableCraftWindow;
      
      public function GuildConsumableCraftSlot(element:DisplayObject, featureName:String = "", window:GuildConsumableCraftWindow = null)
      {
         super(element);
         this.m_featureName = featureName;
         this.m_owner = window;
         if(m_element.hasOwnProperty("icon_mc"))
         {
            addWidget(this.m_consumableIcon = new FarmIcon(m_element.icon_mc));
         }
         if(m_element.hasOwnProperty("count_tf"))
         {
            this.m_countTf = addWidget(new ZwTextField(m_element.count_tf," ")) as ZwTextField;
         }
         if(m_element.hasOwnProperty("make_bt"))
         {
            addWidget(this.m_makeBt = new FarmAnimatedTextButton(m_element["make_bt"],"Make",this.onMakeButtonClick));
         }
         if(m_element.hasOwnProperty("buy_bt"))
         {
            addWidget(this.m_buyBt = new FarmAnimatedCashButton(m_element["buy_bt"],"Buy","3",this.onBuyButtonClick));
         }
      }
      
      override public function populate(data:Object) : void
      {
         var consumable0:FarmItem = null;
         var m_consumable0Icon:FarmIcon = null;
         var consumable1:FarmItem = null;
         var m_consumable1Icon:FarmIcon = null;
         var consumable2:FarmItem = null;
         var m_consumable2Icon:FarmIcon = null;
         super.populate(data);
         this.m_data = data;
         if(this.m_data)
         {
            this.m_consumableFarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.key);
            this.m_pkgName = this.m_data.pkgName;
            this.m_pkgItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_pkgName);
            this.m_index = this.m_data.index;
            this.m_pkgReq = this.m_data.req;
            if(this.m_consumableIcon)
            {
               this.m_consumableIcon.setIconSize(ICON_SIZE,ICON_SIZE);
               this.m_consumableIcon.setSmoothing(true);
               this.m_consumableIcon.visible = true;
               this.m_consumableIcon.loadIcon(this.m_pkgItem.iconUrl);
               if(this.m_consumableIcon.tooltip)
               {
                  this.m_consumableIcon.tooltip.release();
               }
               this.m_consumableIcon.detachTooltip();
               this.m_consumableIcon.attachTooltip(new FarmTextTooltip(this.m_pkgItem.friendlyTitle));
            }
            this.setMakeButton();
            this.setBuyButton();
            if(m_element.hasOwnProperty("req0_mc"))
            {
               this.m_req0_mc = m_element["req0_mc"] as MovieClip;
               this.m_req0_mc.visible = true;
               consumable0 = Global.farmGameSettingsManager.getFarmItemByCode(this.m_data.consumable0);
               if(this.m_req0_mc.hasOwnProperty("icon_mc"))
               {
                  m_consumable0Icon = new FarmIcon(this.m_req0_mc["icon_mc"] as MovieClip);
                  m_consumable0Icon.setIconSize(ICON_REQ_SIZE,ICON_REQ_SIZE);
                  m_consumable0Icon.setSmoothing(true);
                  m_consumable0Icon.visible = true;
                  m_consumable0Icon.loadIcon(consumable0.iconUrl);
                  if(m_consumable0Icon.tooltip)
                  {
                     m_consumable0Icon.tooltip.release();
                  }
                  m_consumable0Icon.detachTooltip();
                  m_consumable0Icon.attachTooltip(new FarmTextTooltip(consumable0.friendlyTitle));
               }
               if(this.m_req0_mc.hasOwnProperty("count_tf"))
               {
                  this.m_count0Tf = new ZwTextField(this.m_req0_mc["count_tf"]);
                  this.m_count0Tf.text = this.getConsumableCount(this.m_data.consumable0).toString() + "/" + this.m_data.count0;
                  this.m_count0Tf.visible = true;
               }
            }
            if(m_element.hasOwnProperty("req1_mc"))
            {
               this.m_req1_mc = m_element["req1_mc"] as MovieClip;
               this.m_req1_mc.visible = true;
               consumable1 = Global.farmGameSettingsManager.getFarmItemByCode(this.m_data.consumable1);
               if(this.m_req1_mc.hasOwnProperty("icon_mc"))
               {
                  m_consumable1Icon = new FarmIcon(this.m_req1_mc["icon_mc"] as MovieClip);
                  m_consumable1Icon.setIconSize(ICON_REQ_SIZE,ICON_REQ_SIZE);
                  m_consumable1Icon.setSmoothing(true);
                  m_consumable1Icon.visible = true;
                  m_consumable1Icon.loadIcon(consumable1.iconUrl);
                  if(m_consumable1Icon.tooltip)
                  {
                     m_consumable1Icon.tooltip.release();
                  }
                  m_consumable1Icon.detachTooltip();
                  m_consumable1Icon.attachTooltip(new FarmTextTooltip(consumable1.friendlyTitle));
               }
               if(this.m_req1_mc.hasOwnProperty("count_tf"))
               {
                  this.m_count1Tf = new ZwTextField(this.m_req1_mc["count_tf"]);
                  this.m_count1Tf.text = this.getConsumableCount(this.m_data.consumable1).toString() + "/" + this.m_data.count1;
                  this.m_count1Tf.visible = true;
               }
            }
            if(m_element.hasOwnProperty("req2_mc"))
            {
               this.m_req2_mc = m_element["req2_mc"] as MovieClip;
               this.m_req2_mc.visible = true;
               consumable2 = Global.farmGameSettingsManager.getFarmItemByCode(this.m_data.consumable2);
               if(this.m_req2_mc.hasOwnProperty("icon_mc"))
               {
                  m_consumable2Icon = new FarmIcon(this.m_req2_mc["icon_mc"] as MovieClip);
                  m_consumable2Icon.setIconSize(ICON_REQ_SIZE,ICON_REQ_SIZE);
                  m_consumable2Icon.setSmoothing(true);
                  m_consumable2Icon.visible = true;
                  m_consumable2Icon.loadIcon(consumable2.iconUrl);
                  if(m_consumable2Icon.tooltip)
                  {
                     m_consumable2Icon.tooltip.release();
                  }
                  m_consumable2Icon.detachTooltip();
                  m_consumable2Icon.attachTooltip(new FarmTextTooltip(consumable2.friendlyTitle));
               }
               if(this.m_req2_mc.hasOwnProperty("count_tf"))
               {
                  this.m_count2Tf = new ZwTextField(this.m_req2_mc["count_tf"]);
                  this.m_count2Tf.text = this.getConsumableCount(this.m_data.consumable2).toString() + "/" + this.m_data.count2;
                  this.m_count2Tf.visible = true;
               }
            }
         }
      }
      
      public function getConsumableCount(consCode:String) : Number
      {
         return int(FeatureOptionsInventoryManager.getInstance().getCount(consCode));
      }
      
      private function get manager() : GuildManager
      {
         return GuildManager.getInstance(this.m_featureName);
      }
      
      public function onMakeButtonClick(event:Event) : void
      {
         this.manager.makeKey(this.m_index);
         if(GuildMainWindow.m_FTUEState == 6)
         {
            ++GuildMainWindow.m_FTUEState;
            if(this.manager.m_guildMainWindow)
            {
               this.manager.m_guildMainWindow.resumeFTUEFlow();
            }
            this.m_owner.close();
         }
      }
      
      public function onBuyButtonClick(event:Event) : void
      {
         var confirmationText:String = ZLocUtils.t("Dialogs","TaskFarmCashBuyConfirmation",{"price":this.m_pkgItem.cash.toString()});
         if(UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptBuyConfirmation,"farmAnimatedCashConfirmation",true,true))
         {
            this.m_buyBt.enabled = false;
            this.m_owner.tintWindow();
            this.m_owner.enableInput = false;
         }
      }
      
      private function onAcceptBuyConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.onClickSkipBuyAfterConfirmation(event);
         }
         else
         {
            this.m_buyBt.enabled = true;
            this.m_owner.untintWindow();
            this.m_owner.enableInput = true;
         }
      }
      
      private function onClickSkipBuyAfterConfirmation(event:Event) : void
      {
         this.manager.buyCraftPackages(this.m_index);
      }
      
      private function setBuyButton() : void
      {
         if(this.m_buyBt)
         {
            this.m_buyBt.visible = true;
            this.m_buyBt.enabled = true;
            this.m_buyBt.setAmountText(this.m_pkgItem.cash.toString());
         }
         if(GuildManager.getInstance().hasGuildKeyCapReached())
         {
            FarmGameUtil.disableButtonAndShowTooltip(this.m_buyBt,"Your token inventory is full");
            this.m_buyBt.callback = null;
         }
      }
      
      private function setMakeButton() : void
      {
         var result:Boolean = false;
         var i:int = 0;
         var consCount:int = 0;
         var req:int = 0;
         if(this.m_makeBt)
         {
            this.m_makeBt.visible = true;
            result = true;
            for(i = 0; i < this.m_index + 1; i++)
            {
               consCount = this.getConsumableCount(this.manager.consumableCodeArray[i]);
               req = int(this.manager.COUNT_ARRAY[this.m_index][i]);
               if(consCount < req)
               {
                  result = false;
                  break;
               }
            }
            this.m_makeBt.enabled = result;
            if(this.m_makeBt.enabled && GuildManager.getInstance().hasGuildKeyCapReached())
            {
               FarmGameUtil.disableButtonAndShowTooltip(this.m_buyBt,"Your token inventory is full");
               this.m_makeBt.callback = null;
            }
            else if(!this.m_makeBt.enabled)
            {
               FarmGameUtil.disableButtonAndShowTooltip(this.m_makeBt,"Collect more ingredients to craft");
               this.m_makeBt.callback = null;
            }
         }
      }
   }
}

