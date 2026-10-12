package Widgets.Slots.Crafting
{
   import Classes.Friend;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.Crafting.CraftedGoodOffering;
   import Managers.Crafting.CraftingManager;
   import Managers.Crafting.MarketViewManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Crafting.CraftingGetGoodsDetailSlotFrame;
   import Widgets.Frames.Crafting.CraftingGetGoodsSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.Crafting.CraftingGetGoodsWindow;
   import ZLocalization.LocalizationName;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class CraftingGetGoodsSlot extends ZwSlotFrame
   {
      
      private var m_userId:String = "-1";
      
      private var m_data:Dictionary = null;
      
      private var m_askFrame:ZwFrame = null;
      
      private var m_craftingGetGoodsSlotFrame:CraftingGetGoodsSlotFrame;
      
      private var m_displayingTimeDialog:Boolean = false;
      
      private var m_craftingGetGoodsWindow:CraftingGetGoodsWindow = null;
      
      private var m_player:Friend = null;
      
      public function CraftingGetGoodsSlot(element:DisplayObject, craftingGetGoodsSlotFrame:CraftingGetGoodsSlotFrame, craftingGetGoodsWindow:CraftingGetGoodsWindow)
      {
         super(element);
         this.m_craftingGetGoodsSlotFrame = craftingGetGoodsSlotFrame;
         this.m_craftingGetGoodsWindow = craftingGetGoodsWindow;
         addWidget(new ZwTextField(m_element.generic_tf));
         addWidget(new ZwTextField(m_element.generic2_tf,ZLocUtils.t("Crafting","CraftingGetGoods_Limit")));
         addWidget(new FarmIcon(m_element.icon_mc));
         addWidget(new CraftingGetGoodsDetailSlotFrame(m_element.get_mc,this.onTakeCallback));
         this.m_askFrame = new ZwFrame(m_element.ask_mc);
         addWidget(this.m_askFrame);
         this.m_askFrame.addWidget(new ZwTextField(m_element.ask_mc.generic_tf));
         this.m_askFrame.addWidget(new FarmAnimatedTextButton(m_element.ask_mc.share_bt,ZLocUtils.t("Crafting","CraftingGetGoods_ShareButton"),this.onShare));
      }
      
      override public function populate(data:Object) : void
      {
         this.updateSlot(data,false);
      }
      
      private function updateSlot(data:Object, displayShareDialog:Boolean) : void
      {
         var inventoryCopyArray:Array = null;
         var friendInventory:Array = null;
         this.m_data = data as Dictionary;
         this.m_userId = this.m_data["uid"];
         if(this.m_userId != "-1")
         {
            this.m_player = Global.friendManager.getFriendData(this.m_userId);
            if(this.m_player)
            {
               (getWidget(m_element.generic_tf) as ZwTextField).text = this.m_player.name;
               (getWidget(m_element.generic_tf) as ZwTextField).visible = true;
               (getWidget(m_element.generic2_tf) as ZwTextField).visible = true;
               (getWidget(m_element.icon_mc) as FarmIcon).visible = true;
               (getWidget(m_element.icon_mc) as FarmIcon).loadIcon(FarmGameUtil.getFriendIconByUid(this.m_userId));
               if(CraftingManager.getInstance().getCraftingBagsAvailableByUser(this.m_userId) != 0)
               {
                  this.m_askFrame.visible = false;
                  this.m_displayingTimeDialog = false;
                  (this.m_askFrame.getWidget(m_element.ask_mc.generic_tf) as ZwTextField).visible = false;
                  (this.m_askFrame.getWidget(m_element.ask_mc.share_bt) as FarmAnimatedTextButton).visible = false;
                  inventoryCopyArray = this.m_data["inventory"].slice(0);
                  friendInventory = this.m_craftingGetGoodsSlotFrame.m_sortOrderLowestFirst ? inventoryCopyArray : inventoryCopyArray.reverse();
                  (getWidget(m_element.get_mc) as CraftingGetGoodsDetailSlotFrame).update(friendInventory);
                  (getWidget(m_element.get_mc) as CraftingGetGoodsDetailSlotFrame).pageNumber = 0;
                  (getWidget(m_element.get_mc) as CraftingGetGoodsDetailSlotFrame).enabled = true;
                  (getWidget(m_element.get_mc) as CraftingGetGoodsDetailSlotFrame).visible = true;
               }
               else
               {
                  this.m_askFrame.visible = true;
                  (this.m_askFrame.getWidget(m_element.ask_mc.generic_tf) as ZwTextField).visible = true;
                  (getWidget(m_element.get_mc) as CraftingGetGoodsDetailSlotFrame).enabled = false;
                  (getWidget(m_element.get_mc) as CraftingGetGoodsDetailSlotFrame).visible = false;
                  if(displayShareDialog)
                  {
                     this.m_displayingTimeDialog = false;
                     (this.m_askFrame.getWidget(m_element.ask_mc.share_bt) as FarmAnimatedTextButton).visible = true;
                  }
                  else
                  {
                     this.m_displayingTimeDialog = true;
                     (this.m_askFrame.getWidget(m_element.ask_mc.share_bt) as FarmAnimatedTextButton).visible = false;
                     this.setComeBackText();
                  }
               }
            }
         }
      }
      
      protected function onCraftedGoodOfferingLoaded(uid:String) : void
      {
         var craftedGoodOffering:CraftedGoodOffering = null;
         if(uid == this.m_userId)
         {
            craftedGoodOffering = MarketViewManager.getInstance().getCraftedGoodOfferingForUser(this.m_userId);
            if(Boolean(craftedGoodOffering) && Boolean(m_element))
            {
               (getWidget(m_element.get_mc) as CraftingGetGoodsDetailSlotFrame).update(craftedGoodOffering.availableInventory);
               (getWidget(m_element.get_mc) as CraftingGetGoodsDetailSlotFrame).visible = true;
               this.m_askFrame.visible = false;
               (this.m_askFrame.getWidget(m_element.ask_mc.generic_tf) as ZwTextField).visible = false;
            }
         }
      }
      
      private function onTakeCallback(slot:CraftingGetGoodsDetailSlot) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(slot.marketInventoryItem.itemCode);
         CraftingManager.getInstance().beginBuyCraftedGood(slot.marketInventoryItem.itemCode,slot.marketInventoryItem.level,this.m_userId,slot.marketInventoryItem.price);
         (this.m_askFrame.getWidget(m_element.ask_mc.generic_tf) as ZwTextField).text = ZLocUtils.t("Crafting","CraftingGetGoods_Share",{
            "item":ZLocUtils.tk_pk(item.friendlyName),
            "friend":ZLocUtils.tn(this.m_player.firstName,ZLocUtils.tg(this.m_player.snUser.gender))
         });
         this.updateSlot(Object(this.m_data),true);
         this.m_craftingGetGoodsWindow.refreshCapacity();
         FarmStatsManager.count("cottage_ui_new","view_get_good_page","user_clicks_get_goods_button ");
      }
      
      private function onShare(event:MouseEvent) : void
      {
         UI.displayPopup(new GenericPopup(ZLocUtils.t("Crafting","CraftingGetGoods_ShareDialog"),GenericPopup.TYPE_ACCEPTCANCEL,this.onShareClose),false);
      }
      
      private function onShareClose(evt:GenericPopupEvent) : void
      {
         if(evt.button == GenericPopup.ACCEPT)
         {
            CraftingManager.getInstance().sendBuyGoodsReward();
         }
         this.updateSlot(Object(this.m_data),false);
      }
      
      override public function release() : void
      {
         super.release();
         this.m_data = null;
         this.m_askFrame = null;
         this.m_craftingGetGoodsSlotFrame = null;
         this.m_craftingGetGoodsWindow = null;
         this.m_player = null;
      }
      
      public function enterFrame() : void
      {
         if(this.m_displayingTimeDialog && Boolean(this.m_player))
         {
            this.setComeBackText();
         }
      }
      
      private function setComeBackText() : void
      {
         var gender:String = "";
         var locName:LocalizationName = null;
         if(this.m_player.snUser != null)
         {
            gender = ZLocUtils.tg(this.m_player.snUser.gender);
         }
         if(gender != "")
         {
            locName = ZLocUtils.tn(this.m_player.firstName,gender);
         }
         else
         {
            locName = ZLocUtils.tn(this.m_player.firstName);
         }
         if(this.m_craftingGetGoodsWindow.timeUntilRolloverDays > 0 && this.m_craftingGetGoodsWindow.timeUntilRolloverHours > 0)
         {
            (this.m_askFrame.getWidget(m_element.ask_mc.generic_tf) as ZwTextField).text = ZLocUtils.t("Crafting","CraftingGetGoods_ComeBackDaysHours",{
               "dayNum":this.m_craftingGetGoodsWindow.timeUntilRolloverDays,
               "hourNum":this.m_craftingGetGoodsWindow.timeUntilRolloverHours,
               "friend":locName
            });
         }
         else if(this.m_craftingGetGoodsWindow.timeUntilRolloverDays > 0)
         {
            (this.m_askFrame.getWidget(m_element.ask_mc.generic_tf) as ZwTextField).text = ZLocUtils.t("Crafting","CraftingGetGoods_ComeBackDays",{
               "dayNum":this.m_craftingGetGoodsWindow.timeUntilRolloverDays,
               "friend":locName
            });
         }
         else if(this.m_craftingGetGoodsWindow.timeUntilRolloverHours > 0 && this.m_craftingGetGoodsWindow.timeUntilRolloverMinutes > 0)
         {
            (this.m_askFrame.getWidget(m_element.ask_mc.generic_tf) as ZwTextField).text = ZLocUtils.t("Crafting","CraftingGetGoods_ComeBackHoursMins",{
               "hourNum":this.m_craftingGetGoodsWindow.timeUntilRolloverHours,
               "minuteNum":this.m_craftingGetGoodsWindow.timeUntilRolloverMinutes,
               "friend":locName
            });
         }
         else if(this.m_craftingGetGoodsWindow.timeUntilRolloverHours > 0)
         {
            (this.m_askFrame.getWidget(m_element.ask_mc.generic_tf) as ZwTextField).text = ZLocUtils.t("Crafting","CraftingGetGoods_ComeBackHours",{
               "hourNum":this.m_craftingGetGoodsWindow.timeUntilRolloverHours,
               "friend":locName
            });
         }
         else if(this.m_craftingGetGoodsWindow.timeUntilRolloverMinutes > 0 && this.m_craftingGetGoodsWindow.timeUntilRolloverSeconds > 0)
         {
            (this.m_askFrame.getWidget(m_element.ask_mc.generic_tf) as ZwTextField).text = ZLocUtils.t("Crafting","CraftingGetGoods_ComeBackMinsSecs",{
               "minuteNum":this.m_craftingGetGoodsWindow.timeUntilRolloverMinutes,
               "secondNum":this.m_craftingGetGoodsWindow.timeUntilRolloverSeconds,
               "friend":locName
            });
         }
         else if(this.m_craftingGetGoodsWindow.timeUntilRolloverMinutes > 0)
         {
            (this.m_askFrame.getWidget(m_element.ask_mc.generic_tf) as ZwTextField).text = ZLocUtils.t("Crafting","CraftingGetGoods_ComeBackMins",{
               "minuteNum":this.m_craftingGetGoodsWindow.timeUntilRolloverMinutes,
               "friend":locName
            });
         }
         else
         {
            (this.m_askFrame.getWidget(m_element.ask_mc.generic_tf) as ZwTextField).text = ZLocUtils.t("Crafting","CraftingGetGoods_ComeBackSecs",{
               "secondNum":this.m_craftingGetGoodsWindow.timeUntilRolloverSeconds,
               "friend":locName
            });
         }
      }
   }
}

