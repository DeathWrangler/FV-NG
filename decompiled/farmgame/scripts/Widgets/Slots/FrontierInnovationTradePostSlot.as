package Widgets.Slots
{
   import Classes.CraftingBasket;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.FrontierInnovationManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FrontierInnovationTradePostWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FrontierInnovationTradePostSlot extends ZwSlotFrame
   {
      
      private static const OFFSET_OPF_Y:int = -20;
      
      private static const ICON_SIZE:int = 100;
      
      private var m_basketName:String;
      
      private var m_data:Object;
      
      private var m_shouldShowCheckMark:Boolean = false;
      
      private var m_shouldShowCommonBg:Boolean = false;
      
      private var m_callbacks:Object;
      
      private var m_countTextField:ZwTextField = null;
      
      private var m_buyButton:FarmAnimatedCashButton = null;
      
      private var m_redeemButton:FarmAnimatedTextButton = null;
      
      private var m_objectPreviewFrame:ObjectPreviewFrame = null;
      
      protected var m_iconPreview:FarmIcon;
      
      private var m_rewardBg:ZwWidget;
      
      private var m_commonRewardBg:ZwWidget;
      
      private var infoTooltip:FarmTextTooltip;
      
      private var m_checkmark:MovieClip;
      
      private var m_icon0Mc:FarmIcon;
      
      private var m_icon1Mc:FarmIcon;
      
      private var m_swapIcon0Mc:FarmIcon;
      
      private var m_swapIcon1Mc:FarmIcon;
      
      private var m_iconMc:FarmIcon;
      
      private var m_icon3Mc:FarmIcon;
      
      private var m_countTf:ZwTextField;
      
      private var m_selectTf:ZwTextField;
      
      private var m_hoverMc:MovieClip;
      
      private var m_discardBt:FarmAnimatedTextButton;
      
      private var m_tradeBt:FarmAnimatedTextButton;
      
      private var m_itemHover:ZwWidget;
      
      private var m_glowMc:MovieClip;
      
      private var m_emptyTf:ZwTextField;
      
      private var m_empty1Tf:ZwTextField;
      
      private var m_empty2Tf:ZwTextField;
      
      private var m_activeTf:ZwTextField;
      
      private var m_titleTf:ZwTextField;
      
      private var m_count1Tf:ZwTextField;
      
      private var m_tradeTf:ZwTextField;
      
      private var m_itemnameTf:ZwTextField;
      
      private var m_item0nameTf:ZwTextField;
      
      private var m_item1nameTf:ZwTextField;
      
      private var m_emojiMc:MovieClip;
      
      private var m_profileMc:FarmIcon;
      
      private var m_expiredMc:MovieClip;
      
      private var m_highlightMc:MovieClip;
      
      private var m_swapMc:MovieClip;
      
      private var m_item0Mc:MovieClip;
      
      private var m_item1Mc:MovieClip;
      
      private var m_item2Mc:MovieClip;
      
      private var m_item3Mc:MovieClip;
      
      private var m_swapItem0Mc:MovieClip;
      
      private var m_swapItem1Mc:MovieClip;
      
      private var m_redeemBt:FarmAnimatedTextButton;
      
      private const HOVER_MC:String = "hover_mc";
      
      private const ICON0_MC:String = "icon0_mc";
      
      private const ICON1_MC:String = "icon1_mc";
      
      private const ICON_MC:String = "icon_mc";
      
      private const COUNT1_TF:String = "count1_mc";
      
      private const COUNT_TF:String = "count_tf";
      
      private const CHECKMARK_MC:String = "checkmark_mc";
      
      private const SELECT_TF:String = "select_tf";
      
      private const ITEM_HOVER:String = "item_hover";
      
      private const HOVER_GLOW:String = "hover_glow";
      
      private const ACTIVE_TF:String = "active_tf";
      
      private const EMPTY_TF:String = "empty_tf";
      
      private const EMPTY1_TF:String = "empty1_tf";
      
      private const TITLE_TF:String = "title_tf";
      
      private const TRADE_TF:String = "trade_tf";
      
      private const ITEMNAME_TF:String = "itemname_tf";
      
      private const ITEM0NAME_TF:String = "item0name_tf";
      
      private const ITEM1NAME_TF:String = "item1name_tf";
      
      private const EMOJI_MC:String = "emoji_mc";
      
      private const PROFILE_MC:String = "profile_mc";
      
      private const EXPIRED_MC:String = "expired_mc";
      
      private const HIGHLIGHT_MC:String = "highlight_mc";
      
      private const ITEMNOTAVAIL_TF:String = "itemnotavail_tf";
      
      private const SWAP_MC:String = "swap_mc";
      
      private const REDEEM_BT:String = "redeem_bt";
      
      private const ITEM0_MC:String = "item0_mc";
      
      private const ITEM1_MC:String = "item1_mc";
      
      private const ITEM2_MC:String = "item2_mc";
      
      private const ITEM3_MC:String = "item3_mc";
      
      private const EMPTY_SLOT:int = 0;
      
      private const TRADE_SUCCESS:int = 2;
      
      private const TRADE_ACTIVE:int = 1;
      
      private const TRADE_EXPIRED:int = 3;
      
      private const TRADE_UNPROCESSED:* = 4;
      
      internal var manager:FrontierInnovationManager;
      
      private var m_featureName:String;
      
      private var m_slotName:String;
      
      private var m_frameName:String;
      
      private var m_slotNumber:int;
      
      private var m_window:FrontierInnovationTradePostWindow;
      
      private var m_confirmPopup:GenericPopup;
      
      internal var index:int;
      
      internal var m_status:int;
      
      internal var m_R1:String;
      
      internal var m_R2:String;
      
      internal var m_userName:String;
      
      internal var m_userPicUrl:String;
      
      public function FrontierInnovationTradePostSlot(featureName:String, element:DisplayObject, window:FrontierInnovationTradePostWindow)
      {
         this.m_featureName = featureName;
         this.m_window = window;
         this.manager = FrontierInnovationManager.getInstance(featureName);
         super(element);
         this.m_slotName = m_element.name;
         this.m_frameName = m_element.parent.name;
         this.m_slotNumber = this.m_window.getSlotNumber(this.m_slotName);
         if(m_element.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(this.m_titleTf = new ZwTextField(m_element[this.TITLE_TF],""));
         }
         if(m_element.hasOwnProperty(this.EMPTY_TF))
         {
            addWidget(this.m_emptyTf = new ZwTextField(m_element[this.EMPTY_TF],"Empty Slot"));
         }
         if(m_element.hasOwnProperty(this.EMPTY1_TF))
         {
            addWidget(this.m_empty1Tf = new ZwTextField(m_element[this.EMPTY1_TF],"Trade an item from Barnhouse"));
         }
         if(m_element.hasOwnProperty(this.ACTIVE_TF))
         {
            addWidget(this.m_activeTf = new ZwTextField(m_element[this.ACTIVE_TF],"Searching for Trader..."));
            this.m_activeTf.visible = false;
         }
         if(m_element.hasOwnProperty(this.TRADE_TF))
         {
            addWidget(this.m_tradeTf = new ZwTextField(m_element[this.TRADE_TF],""));
         }
         if(m_element.hasOwnProperty(this.EMOJI_MC))
         {
            this.m_emojiMc = m_element[this.EMOJI_MC] as MovieClip;
         }
         if(m_element.hasOwnProperty(this.PROFILE_MC))
         {
            addWidget(this.m_profileMc = new FarmIcon(m_element[this.PROFILE_MC]));
         }
         if(m_element.hasOwnProperty(this.EXPIRED_MC))
         {
            this.m_expiredMc = m_element[this.EXPIRED_MC] as MovieClip;
            if(this.m_expiredMc.hasOwnProperty(this.ICON_MC))
            {
               addWidget(this.m_iconMc = new FarmIcon(this.m_expiredMc[this.ICON_MC]));
            }
            if(this.m_expiredMc.hasOwnProperty(this.ITEMNAME_TF))
            {
               addWidget(this.m_itemnameTf = new ZwTextField(this.m_expiredMc[this.ITEMNAME_TF],""));
            }
         }
         if(m_element.hasOwnProperty(this.HIGHLIGHT_MC))
         {
            this.m_highlightMc = m_element[this.HIGHLIGHT_MC] as MovieClip;
         }
         if(m_element.hasOwnProperty(this.SWAP_MC))
         {
            this.m_swapMc = m_element[this.SWAP_MC] as MovieClip;
            if(this.m_swapMc.hasOwnProperty(this.ICON0_MC))
            {
               addWidget(this.m_swapIcon0Mc = new FarmIcon(this.m_swapMc[this.ICON0_MC]));
            }
            if(this.m_swapMc.hasOwnProperty(this.ICON1_MC))
            {
               addWidget(this.m_swapIcon1Mc = new FarmIcon(this.m_swapMc[this.ICON1_MC]));
            }
            if(this.m_swapMc.hasOwnProperty(this.ITEM0NAME_TF))
            {
               addWidget(this.m_item0nameTf = new ZwTextField(this.m_swapMc[this.ITEM0NAME_TF],""));
            }
            if(this.m_swapMc.hasOwnProperty(this.ITEM1NAME_TF))
            {
               addWidget(this.m_item1nameTf = new ZwTextField(this.m_swapMc[this.ITEM1NAME_TF],""));
            }
         }
         if(m_element.hasOwnProperty(this.REDEEM_BT))
         {
            addWidget(this.m_redeemBt = new FarmAnimatedTextButton(m_element[this.REDEEM_BT],"",this.onRedeemButton));
         }
      }
      
      override public function populate(data:Object) : void
      {
         var item:FarmItem = null;
         var randomName:Array = null;
         super.populate(data[0]);
         this.m_data = data[0];
         this.m_status = this.m_data["Status"];
         this.m_R1 = this.m_data["R1"];
         this.m_R2 = this.m_data["R2"];
         this.m_userName = this.m_data["userName"];
         this.m_userPicUrl = this.m_data["userPic"];
         if(this.m_userName == null)
         {
            randomName = ["James","John","Robert","Michael","William","David","Richard","Joseph","Thomas","Charles","Christopher","Daniel","Matthew","Anthony","Donald","Mark","Paul","Steven","Andrew","Kenneth","George","Joshua","Kevin","Brian","Edward","Ronald","Timothy","Jason","Jeffrey","Ryan","Jacob","Gary","Nicholas","Eric","Stephen","Jonathan","Larry","Justin","Scott","Brandon","Frank","Benjamin","Gregory","Raymond","Samuel","Patrick","Alexander","Jack","Dennis","Jerry","Mary","Patricia","Jennifer","Linda","Elizabeth","Barbara","Susan","Jessica","Sarah","Margaret","Karen","Nancy","Lisa","Betty","Dorothy","Sandra","Ashley","Kimberly","Donna","Emily","Carol","Michelle","Amanda","Melissa","Deborah","Stephanie","Rebecca","Laura","Helen","Sharon","Cynthia","Kathleen","Amy","Shirley","Angela","Anna","Ruth","Brenda","Pamela","Nicole","Katherine","Samantha","Christine","Catherine","Virginia","Debra","Rachel","Janet","Emma","Carolyn"];
            this.m_userName = randomName[Math.floor(Math.random() * 100)];
            this.m_userPicUrl = "https://scontent-bom1-1.xx.fbcdn.net/v/t31.0-1/c379.0.1290.1290/10506738_10150004552801856_220367501106153455_o.jpg?_nc_cat=0&oh=31ac7a3ccadcecb2145cef9bf00fb64f&oe=5BE3057C";
            StatsManager.count(this.m_featureName,"DummyTrade",this.m_R1,this.m_R2);
         }
         if(this.m_status == this.EMPTY_SLOT)
         {
            this.m_emptyTf.visible = true;
            this.m_empty1Tf.visible = true;
            this.m_titleTf.visible = false;
            this.m_tradeTf.visible = false;
            this.m_activeTf.visible = false;
            this.m_emojiMc.visible = false;
            this.m_profileMc.visible = false;
            this.m_expiredMc.visible = false;
            this.m_iconMc.visible = false;
            this.m_itemnameTf.visible = false;
            this.m_highlightMc.visible = false;
            this.m_swapMc.visible = false;
            this.m_swapIcon0Mc.visible = false;
            this.m_item0nameTf.visible = false;
            this.m_item1nameTf.visible = false;
            this.m_swapIcon1Mc.visible = false;
            this.m_redeemBt.visible = false;
         }
         else if(this.m_status == this.TRADE_SUCCESS)
         {
            this.m_swapMc.visible = true;
            item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_R2);
            this.m_swapIcon0Mc.loadIcon(item.icon);
            this.m_swapIcon0Mc.setIconSize(50,50);
            this.m_swapIcon0Mc.visible = true;
            this.m_item0nameTf.text = item.friendlyTitle;
            this.m_item0nameTf.visible = true;
            item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_R1);
            this.m_swapIcon1Mc.loadIcon(item.icon);
            this.m_swapIcon1Mc.setIconSize(50,50);
            this.m_swapIcon1Mc.visible = true;
            this.m_item1nameTf.text = item.friendlyTitle;
            this.m_item1nameTf.visible = true;
            this.m_emojiMc.visible = true;
            this.m_profileMc.loadIcon(this.m_userPicUrl);
            this.m_profileMc.setIconSize(30,30);
            this.m_profileMc.visible = true;
            this.m_tradeTf.text = this.m_userName + " traded with you!";
            this.m_tradeTf.visible = true;
            this.m_titleTf.text = "Trade Successful";
            this.m_titleTf.visible = true;
            this.m_redeemBt.text = "Collect";
            this.m_redeemBt.visible = true;
            this.m_emptyTf.visible = false;
            this.m_empty1Tf.visible = false;
            this.m_expiredMc.visible = false;
            this.m_iconMc.visible = false;
            this.m_itemnameTf.visible = false;
            this.m_activeTf.visible = false;
            this.m_highlightMc.visible = false;
         }
         else if(this.m_status == this.TRADE_ACTIVE || this.m_status == this.TRADE_UNPROCESSED)
         {
            this.m_swapMc.visible = true;
            item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_R2);
            this.m_swapIcon0Mc.loadIcon(item.icon);
            this.m_swapIcon0Mc.setIconSize(50,50);
            this.m_swapIcon0Mc.visible = true;
            this.m_item0nameTf.text = item.friendlyTitle;
            this.m_item0nameTf.visible = true;
            item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_R1);
            this.m_swapIcon1Mc.loadIcon(item.icon);
            this.m_swapIcon1Mc.setIconSize(50,50);
            this.m_swapIcon1Mc.visible = true;
            this.m_item1nameTf.text = item.friendlyTitle;
            this.m_item1nameTf.visible = true;
            this.m_activeTf.visible = true;
            this.m_titleTf.text = "Active Trade";
            this.m_titleTf.visible = true;
            this.m_emojiMc.visible = false;
            this.m_emptyTf.visible = false;
            this.m_empty1Tf.visible = false;
            this.m_tradeTf.visible = false;
            this.m_profileMc.visible = false;
            this.m_expiredMc.visible = false;
            this.m_iconMc.visible = false;
            this.m_itemnameTf.visible = false;
            this.m_highlightMc.visible = false;
            this.m_redeemBt.visible = false;
         }
         else if(this.m_status == this.TRADE_EXPIRED)
         {
            this.m_expiredMc.visible = true;
            item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_R2);
            this.m_iconMc.loadIcon(item.icon);
            this.m_iconMc.setIconSize(50,50);
            this.m_iconMc.visible = true;
            this.m_itemnameTf.text = item.friendlyTitle;
            this.m_itemnameTf.visible = true;
            this.m_titleTf.text = "Trade Expired";
            this.m_titleTf.visible = true;
            this.m_tradeTf.text = "No Trader Found";
            this.m_tradeTf.visible = true;
            this.m_redeemBt.text = "Reclaim";
            this.m_redeemBt.visible = true;
            this.m_emojiMc.visible = false;
            this.m_emptyTf.visible = false;
            this.m_empty1Tf.visible = false;
            this.m_activeTf.visible = false;
            this.m_profileMc.visible = false;
            this.m_highlightMc.visible = false;
            this.m_swapMc.visible = false;
            this.m_swapIcon0Mc.visible = false;
            this.m_item0nameTf.visible = false;
            this.m_swapIcon1Mc.visible = false;
            this.m_item1nameTf.visible = false;
         }
      }
      
      private function onRedeemButton(event:Event) : void
      {
         var buttonAction:String = this.m_redeemBt.text.toString();
         if(buttonAction == "Collect")
         {
            if(this.manager.isBarnCapacityFull())
            {
               this.visitBarnPopUp();
            }
            else
            {
               this.m_window.tintWindow();
               this.m_window.enableInput = false;
               this.m_redeemBt.enabled = false;
               FarmStatsManager.count(this.m_featureName,"BarnHouse","Collect",this.m_R1);
               this.manager.successTradePost(this.m_slotNumber);
            }
         }
         else if(buttonAction == "Reclaim")
         {
            if(this.manager.isBarnCapacityFull())
            {
               this.visitBarnPopUp();
            }
            else
            {
               this.m_redeemBt.enabled = false;
               FarmStatsManager.count(this.m_featureName,"BarnHouse","Reclaim",this.m_R2);
               this.m_window.tintWindow();
               this.m_window.enableInput = false;
               this.manager.failureTradePost(this.m_slotNumber);
            }
         }
      }
      
      public function visitBarnPopUp() : void
      {
         var sellMessage:String = "You do not have enough space in the Barnhouse. Please discard resources or upgrade it to get more capacity.";
         this.m_confirmPopup = new GenericPopup(sellMessage,GenericPopup.TYPE_OK,this.onVisitBarn);
         this.m_confirmPopup.setAcceptTextName("VisitBarnHouse");
         UI.displayPopup(this.m_confirmPopup,false,"Barn_Capacity_Full",true);
      }
      
      public function onVisitBarn(evt:GenericPopupEvent) : void
      {
         this.manager.visitBarnUIFromTradePost();
      }
      
      private function onBuyItem(event:Event) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.name);
         UI.displayMessage(ZLocUtils.t("Dialogs",this.m_basketName + "BuyConfirmPopup",{
            "cashQuantity":item.cash,
            "item":item.friendlyTitle
         }),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmBuyItemPopupClose,"",true);
      }
      
      private function onConfirmBuyItemPopupClose(event:GenericPopupEvent) : void
      {
         var callback:Function = null;
         if(event.button == GenericPopup.YES)
         {
            callback = this.m_callbacks[CraftingBasket.BUY_ITEM];
            callback(this.m_data.name);
         }
      }
      
      private function onRedeemItem(event:Event) : void
      {
         var callback:Function = this.m_callbacks[CraftingBasket.REDEEM_ITEM];
         callback(this.m_data.name);
      }
      
      public function toggleRedeemVisible(visible:Boolean) : void
      {
         if(visible)
         {
            this.m_redeemButton.enabled = true;
            this.m_redeemButton.applyGrayOut = false;
         }
         else
         {
            this.m_redeemButton.enabled = false;
            this.m_redeemButton.applyGrayOut = true;
         }
      }
   }
}

