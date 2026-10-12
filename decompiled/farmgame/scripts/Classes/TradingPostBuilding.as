package Classes
{
   import Classes.Trading.TradingPostConstants;
   import Classes.Trading.TradingPostManager;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import GameMode.GMBuild;
   import Managers.FarmStatsManager;
   import Widgets.Windows.ArrowIndicatorWindow;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class TradingPostBuilding extends StorageBuilding
   {
      
      protected var ACTION_MENU_LOOK_INSIDE:String = "_look_inside";
      
      private const ARROW_INDICATOR_BUY_FRIEND_GOODS:String = "buy_goods_arrow";
      
      private const ARROW_INDICATOR_NONE:String = "none";
      
      protected var m_arrowCurrentlyHidden:Boolean = true;
      
      public function TradingPostBuilding(buildingType:String = null)
      {
         super(buildingType);
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case this.ACTION_MENU_LOOK_INSIDE:
                  TradingPostManager.getInstance().showTradingPostWindow();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      override public function onClick() : void
      {
         FarmStatsManager.count(TradingPostConstants.STATS_TRADINGPOST_COUNTER,"trading_post_clicked");
         super.onClick();
      }
      
      override public function showMenu() : void
      {
         var arrowIndicatorType:String = this.getArrowIndicatorType();
         switch(arrowIndicatorType)
         {
            case this.ARROW_INDICATOR_BUY_FRIEND_GOODS:
               TradingPostManager.getInstance().showTradingPostWindow();
               this.removeArrowIndicator();
               break;
            case this.ARROW_INDICATOR_NONE:
            default:
               m_menuItems.push({
                  "label":ZLocUtils.t("Dialogs",this.getItem().name + this.ACTION_MENU_LOOK_INSIDE),
                  "action":this.ACTION_MENU_LOOK_INSIDE
               });
               super.showMenu();
         }
         Global.player.setSeenSessionFlag("clickedArrow");
      }
      
      override protected function onBuilt() : void
      {
         var message:String = ZLocUtils.t("Dialogs",this.getItem().name + "_FirstTimePlace");
         var iconPopup:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onBuiltShare,this.getItem().icon);
         FarmStatsManager.count(TradingPostConstants.STATS_TRADINGPOST_COUNTER,"trading_post_placed");
         UI.displayPopup(iconPopup,false);
      }
      
      protected function onBuiltShare(event:GenericPopupEvent) : void
      {
         var bundleData:Object = null;
         var messageType:String = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            bundleData = {
               "images":[{
                  "href":"{SN_APP_URL}?ref=trading_post_on_built",
                  "src":this.getItem().icon
               }],
               "user":Global.player.firstName
            };
            messageType = this.getItem().name + "_FirstTimePlace";
            GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,[],false);
         }
      }
      
      private function getArrowIndicatorType() : String
      {
         var hasSeenArrow:Boolean = false;
         var type:String = this.ARROW_INDICATOR_NONE;
         var currentGMs:Array = Global.world.getActiveGameModes();
         if(!(Global.worldManager.isVisiting() || currentGMs[0] is GMBuild || UI.isShowingPopup()))
         {
            hasSeenArrow = Global.player.getSeenSessionFlag("clickedArrow");
            if(!hasSeenArrow && TradingPostManager.getInstance().getFriendsWithSellingGoods().length > 0)
            {
               type = this.ARROW_INDICATOR_BUY_FRIEND_GOODS;
            }
         }
         return type;
      }
      
      private function createArrowIndicator(arrowIndicatorType:String) : DisplayObject
      {
         var friendsWithGoods:Array = null;
         var friendIdx:int = 0;
         var friend:Friend = null;
         var arrowIndicator:DisplayObject = null;
         var iconUrl:String = "";
         var counter:int = 0;
         var canShowCounterIcon:Boolean = false;
         var titleLocalizeKey:String = this.getItem().name + "_Title_" + arrowIndicatorType;
         switch(arrowIndicatorType)
         {
            case this.ARROW_INDICATOR_BUY_FRIEND_GOODS:
               friendsWithGoods = TradingPostManager.getInstance().getFriendsWithSellingGoods();
               counter = int(friendsWithGoods.length);
               canShowCounterIcon = true;
               if(friendsWithGoods.length > 0)
               {
                  friendIdx = Math.round(Math.random() * (friendsWithGoods.length - 1));
                  friend = Global.friendManager.getFriendData(friendsWithGoods[friendIdx]);
                  if(friend)
                  {
                     iconUrl = friend.picture;
                  }
               }
         }
         var title:String = ZLocUtils.t("Dialogs",titleLocalizeKey,{
            "friendCount":counter,
            "friend_word":ZLocUtils.tk("Dialogs","friend_word","",counter)
         });
         var text:String = ZLocUtils.t("Dialogs",this.getItem().name + "_Text_" + arrowIndicatorType);
         var counterText:String = canShowCounterIcon ? counter.toString() : null;
         return new ArrowIndicatorWindow(iconUrl,title,text,counterText);
      }
      
      override protected function replaceContent(newContent:DisplayObject, shouldRedrawMask:Boolean = false) : void
      {
         super.replaceContent(newContent,shouldRedrawMask);
         this.checkArrowIndicator();
      }
      
      private function checkArrowIndicator() : void
      {
         var arrowIndicatorType:String = null;
         var spr:Sprite = null;
         if(!m_usingLoadingGraphic)
         {
            arrowIndicatorType = this.getArrowIndicatorType();
            m_hideArrow = this.ARROW_INDICATOR_NONE == arrowIndicatorType;
            if(this.m_arrowCurrentlyHidden != m_hideArrow)
            {
               if(m_hideArrow)
               {
                  this.removeArrowIndicator();
               }
               else
               {
                  spr = m_displayObject as Sprite;
                  if(m_arrow == null && spr.numChildren > 0)
                  {
                     m_arrow = this.createArrowIndicator(arrowIndicatorType);
                     if(m_arrow)
                     {
                        m_arrow.visible = true;
                        (m_displayObject as Sprite).addChild(m_arrow);
                        setArrowPosition();
                     }
                     this.m_arrowCurrentlyHidden = false;
                  }
               }
            }
         }
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         super.onMouseOver(event);
         this.updateArrowIndicator();
      }
      
      override public function onMouseOut() : void
      {
         super.onMouseOut();
         this.updateArrowIndicator();
      }
      
      private function updateArrowIndicator() : void
      {
         var arrowIndicatorWindow:ArrowIndicatorWindow = null;
         if(Global.selectedAvatar)
         {
            arrowIndicatorWindow = m_arrow as ArrowIndicatorWindow;
            if(arrowIndicatorWindow)
            {
               arrowIndicatorWindow.showRolloverText(isHighlighted());
            }
         }
      }
      
      public function removeArrowIndicator() : void
      {
         if(Boolean(m_arrow) && Boolean(m_arrow.visible) && m_arrow.parent != null)
         {
            m_arrow.visible = false;
            m_arrow.parent.removeChild(m_arrow);
            m_arrow = null;
            conditionallyRedraw(true);
            this.m_arrowCurrentlyHidden = true;
            m_hideArrow = true;
         }
      }
      
      override protected function updateToolTipText() : void
      {
         var counter:Number = NaN;
         var toolTip:String = ZLocUtils.tk_pk_asTitle(m_item.friendlyName);
         if(Global.worldManager.isVisiting() == false)
         {
            counter = 0;
            if(TradingPostManager.getInstance().marketView != null)
            {
               counter = TradingPostManager.getInstance().marketView.getAllFriendOfferingsSafe().length;
               if(counter > 0)
               {
                  toolTip += "\n" + ZLocUtils.t("Dialogs","tradingpost_tooltip_selling",{
                     "friendCount":counter,
                     "friend_word":ZLocUtils.tk("Dialogs","friend_word","",counter)
                  });
               }
            }
            counter = TradingPostManager.getInstance().getTotalFriendOrders();
            if(counter > 0)
            {
               toolTip += "\n" + ZLocUtils.t("Dialogs","tradingpost_tooltip_orders",{
                  "friendCount":counter,
                  "order_word":ZLocUtils.tk("Dialogs","order_word","",counter)
               });
            }
         }
         setToolTip(toolTip);
         updateToolTipPosition();
      }
      
      override public function getCurrentImageName() : String
      {
         return "built";
      }
   }
}

