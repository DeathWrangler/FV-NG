package Classes
{
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.HolidayTreeWithdrawal;
   import Display.UI;
   import Engine.IsoMath;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class HolidayTreeStorage extends StorageBuilding
   {
      
      protected const ASK_FRIENDS_FOR_GIFT:String = "askFriendsForGift";
      
      private var m_lastRewardUrl:String;
      
      public function HolidayTreeStorage(buildingType:String = null)
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
               case this.ASK_FRIENDS_FOR_GIFT:
                  FarmStatsManager.count("holidaytree","askgifts","contextual");
                  this.popFeed("HolidayTree_AskFriends");
                  break;
               case REMOVEFROM_OBJECT:
                  FarmStatsManager.count("holidaytree","lookinside");
                  super.onMenuClick(event);
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      override public function isSellable() : Boolean
      {
         return true;
      }
      
      public function popFeed(bundleId:String, params:Object = null) : void
      {
         if(params == null)
         {
            params = new Object();
         }
         if(params.hasOwnProperty("images") == false)
         {
            params.images = [{
               "src":getItem().getImageByName("icon"),
               "href":"{SN_APP_URL}{creative:picture}index.php"
            }];
         }
         GlobalEngine.socialNetwork.publishFeedStory(bundleId,params,[],false);
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         UI.displayStorageDialog(new HolidayTreeWithdrawal(this));
      }
      
      override public function onBuildComplete(result:Object) : void
      {
         super.onBuildComplete(result);
         Global.player.setSeenFlag("hasPlaceHolidayTree");
         Global.hud.iconQueue.removeIconByName("Xmas_Tree");
         FarmStatsManager.count("holidaytree","place");
      }
      
      override protected function updateToolTipText() : void
      {
         var toolTip:String = null;
         if(isHighlighted() && Global.worldManager.isVisiting() == false)
         {
            toolTip = ZLocUtils.tk_pk_asTitle(m_item.friendlyName);
            toolTip += "\n" + ZLocUtils.t("Items",m_item.name + "_capacity",{
               "quantity":count,
               "maximum":capacity
            });
         }
         else if(isHighlighted() && Global.worldManager.isVisiting() == true)
         {
            toolTip = ZLocUtils.tk_pk_asTitle(m_item.friendlyName);
         }
         setToolTip(toolTip);
         updateToolTipPosition();
      }
      
      override public function displayStatusStartPos() : Point
      {
         var screen:Point = IsoMath.tilePosToPixelPos(m_position.x,m_position.y);
         if(m_displayObject)
         {
            screen.y -= m_displayObject.height / 2;
         }
         return IsoMath.viewportToStage(screen);
      }
      
      override protected function getOverlayStartPos() : Point
      {
         return new Point(this.getScreenPosition().x,this.getScreenPosition().y + m_displayObject.height / 2);
      }
      
      override protected function shouldShowOverlayOnAdd() : Boolean
      {
         return false;
      }
      
      override public function onStoreComplete(result:Object) : void
      {
         var popupMessage:String = null;
         var curAmount:int = 0;
         super.onStoreComplete(result);
         if(result.rewardUrl)
         {
            this.m_lastRewardUrl = result.rewardUrl;
            popupMessage = "HolidayTree_treereward";
            curAmount = m_count + Global.player.numOpenedPresents;
            if(curAmount == 1)
            {
               popupMessage = "HolidayTree_firstpresent";
            }
            else if(curAmount == m_capacity)
            {
               popupMessage = "HolidayTree_maxcapacity";
            }
            else if(curAmount % 20 == 0 && curAmount < m_capacity)
            {
               popupMessage = "HolidayTree_treechanged";
            }
            UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs",popupMessage,{"quantity":20}),GenericPopup.TYPE_SHARECANCEL,this.popRewardFeed));
         }
      }
      
      private function popRewardFeed(event:GenericPopupEvent) : void
      {
         var feed:String = null;
         var params:Object = null;
         var curAmount:int = 0;
         if(event.button == GenericPopup.ACCEPT)
         {
            feed = "HolidayTree_TreeReward";
            params = new Object();
            curAmount = m_count + Global.player.numOpenedPresents;
            if(curAmount == m_capacity)
            {
               feed = "HolidayTree_MaxCapacity";
               params.images = [{
                  "src":getItem().getImageByName("max_icon"),
                  "href":"{SN_APP_URL}{creative:picture}index.php"
               }];
            }
            else if(curAmount % 20 == 0 && curAmount < m_capacity)
            {
               feed = "HolidayTree_TreeChanged";
            }
            params.reward_link = this.m_lastRewardUrl;
            this.popFeed(feed,params);
         }
      }
      
      override public function getCurrentSuffix() : int
      {
         var intervalBreak:int = 0;
         var curAmount:int = 0;
         var result:int = 0;
         if(m_numImageStates > 1)
         {
            intervalBreak = m_capacity / (m_numImageStates - 1);
            curAmount = m_count + Global.player.numOpenedPresents;
            if(curAmount > m_capacity)
            {
               curAmount = m_capacity;
            }
            result = int(Math.floor(curAmount / intervalBreak));
         }
         return result;
      }
   }
}

