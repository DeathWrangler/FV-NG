package Widgets.Windows.MOTD
{
   import Classes.ZItem.FarmItem;
   import Classes.util.EventBatchEvent;
   import Classes.util.EventBatcher;
   import Display.GenericPopupTitle;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FVV10ReceivedBirthdayCard;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   
   public class FarmvilleAnniversaryV10BirthdayCard extends GenericSingleButtonWidgetMOTD
   {
      
      private static const SEARCH_INPUT_BATCHING_MIN_DELAY:int = 250;
      
      private static const SEARCH_INPUT_BATCHING_MAX_DELAY:int = 1000;
      
      private static const DEFAULT_SEARCH_TEXT:String = "Search";
      
      private static const SENT:int = 0;
      
      private static const RECEIVED:int = 1;
      
      private static const MESSAGES:Array = ["Happy Farmville Birthday! Lettuce Turnip The Beet and step into a new year of farm and frolic!","I’m rooting for us because Farmville and we will live Apple-y ever after! Happy Farmville Birthday!","I’m so lucky to have met you, we make the PEARfect friends! Berry Berry Happy Farmville Birthday!","I love you from my head Tomatoes! You’re one in a Melon, Happy Farmville Birthday!"];
      
      private static const GIFTS:Array = ["rhino_birthdaygift","chicken_birthdaybash","elephant_birthdaybaloon","moose_gifthorn","horse_giftwrapped","sheep_birthdaybash","dragon_celebrationdragicorn","babyanimal_surprisegiftpuppy","dog_giftinggy","genanimal_giftbringerreindeer"];
      
      private var m_selectedGift:FarmItem;
      
      private var m_selectedFriend:Object;
      
      private var m_selectedMessage:String;
      
      private var m_currentPage:Number = 1;
      
      private var m_numFriendSlots:Number;
      
      private var m_numFriendSlotsToShow:Number;
      
      private var m_allFriends:Array;
      
      private var m_friendsToShow:Array;
      
      private var m_giftMC:MovieClip;
      
      private var m_giftitMC:MovieClip;
      
      private var m_friendMC:MovieClip;
      
      private var m_selectMC:MovieClip;
      
      private var m_playersMC:MovieClip;
      
      private var m_overlayMC:MovieClip;
      
      private var m_giftTF:ZwTextField;
      
      private var m_bodyTF:ZwTextField;
      
      private var m_titleTF:ZwTextField;
      
      private var m_friendTF:ZwTextField;
      
      private var m_playerPageTF:ZwTextField;
      
      private var m_giftIconMC:FarmIcon;
      
      private var m_friendIconMC:FarmIcon;
      
      private var m_openMessageFrameBT:FarmAnimatedTextButton;
      
      private var m_giftAcceptBT:FarmAnimatedTextButton;
      
      private var m_openGiftsFrameBT:FarmAnimatedTextButton;
      
      private var m_playerAcceptBT:FarmAnimatedTextButton;
      
      private var m_openFriendsFrameBT:FarmAnimatedTextButton;
      
      private var m_playerNextPageBT:ZwButton;
      
      private var m_playerPrevPageBT:ZwButton;
      
      private var m_searchBarMC:ZwWidget;
      
      private var m_searchFieldTF:ZwTextField;
      
      private var m_clearSearchBT:FarmAnimatedButton;
      
      private var m_searchFieldInputBatcher:EventBatcher;
      
      private var m_searchMC:ZwWidget;
      
      private var m_messageTFs:Array = [];
      
      private var m_messageSelectBTs:Array = [];
      
      private var m_messageCheckmarksMCs:Array = [];
      
      private var m_playerNameTFs:Array = [];
      
      private var m_playerIcons:Array = [];
      
      private var m_playerSlots:Array = [];
      
      private var m_playerSelectBTs:Array = [];
      
      private var m_playerCheckmarksMCs:Array = [];
      
      private var m_giftIcons:Array = [];
      
      private var m_giftSelectBTs:Array = [];
      
      private var m_giftCheckmarksMCs:Array = [];
      
      private var m_confirmMessageBT:FarmAnimatedTextButton;
      
      public function FarmvilleAnniversaryV10BirthdayCard(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      private static function showGiftPopUp(giftsData:Object) : void
      {
         var giftData:Object = null;
         for each(giftData in giftsData)
         {
            FarmStatsManager.count("FVAnniversaryV10","birthday_card",String(giftData.fromUID),giftData.message,giftData.itemName,Global.worldManager.currentWorldType,RECEIVED);
            Global.player.addGift(giftData.itemName);
            UI.displayPopup(new FVV10ReceivedBirthdayCard(giftData),false);
         }
      }
      
      public static function showReceivedGiftCard() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction("FVV10AnniversaryBirthdayCardService","getGiftForUser",showGiftPopUp,[Global.player.uid]));
      }
      
      override protected function postLoadComplete() : void
      {
         var i:int = 0;
         var index:int = 0;
         var playerSlot:MovieClip = null;
         var giftItem:FarmItem = null;
         var giftSlot:MovieClip = null;
         if(m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow["title_tf"])
            {
               this.m_titleTF = addWidget(new ZwTextField(m_window.mainWindow["title_tf"],"Send a Birthday Gift!")) as ZwTextField;
               this.m_titleTF.visible = true;
            }
            if(m_window.mainWindow["body_tf"])
            {
               this.m_bodyTF = addWidget(new ZwTextField(m_window.mainWindow["body_tf"],"Select a greeting you want to send to your friend")) as ZwTextField;
               this.m_bodyTF.visible = true;
            }
            if(m_window.mainWindow["choose_bt"])
            {
               this.m_openMessageFrameBT = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.choose_bt,"Select",this.onOpenMessageFrameButtonClick)) as FarmAnimatedTextButton;
               this.m_openMessageFrameBT.visible = true;
            }
            if(m_window.mainWindow["select_mc"])
            {
               this.m_selectMC = m_window.mainWindow["select_mc"] as MovieClip;
               for(i = 0; i < 4; i++)
               {
                  if(this.m_selectMC["checkmark" + (i + 1).toString() + "_mc"])
                  {
                     this.m_messageCheckmarksMCs[i] = this.m_selectMC["checkmark" + (i + 1).toString() + "_mc"] as MovieClip;
                     this.m_messageCheckmarksMCs[i].visible = false;
                  }
                  if(this.m_selectMC["message" + (i + 1).toString() + "_tf"])
                  {
                     this.m_messageTFs[i] = new ZwTextField(this.m_selectMC["message" + (i + 1).toString() + "_tf"],MESSAGES[i]);
                     this.m_messageTFs[i].visible = true;
                  }
                  if(this.m_selectMC["select" + (i + 1).toString() + "_bt"])
                  {
                     this.m_messageSelectBTs[i] = new FarmAnimatedTextButton(this.m_selectMC["select" + (i + 1).toString() + "_bt"],"Select");
                     this.m_messageSelectBTs[i].callback = this.onSelectMessageButtonClick(i);
                     this.m_messageSelectBTs[i].visible = true;
                  }
               }
               this.m_confirmMessageBT = new FarmAnimatedTextButton(m_window.mainWindow.select_mc.accept_bt,"Continue",this.onConfirmMessageButtonClick);
               this.m_selectMC.visible = false;
            }
            if(m_window.mainWindow["overlay_mc"])
            {
               this.m_overlayMC = m_window.mainWindow["overlay_mc"] as MovieClip;
               this.m_overlayMC.visible = false;
            }
            if(m_window.mainWindow["players_mc"])
            {
               this.m_playersMC = m_window.mainWindow["players_mc"] as MovieClip;
               index = 0;
               while(this.m_playersMC["player" + index.toString() + "_mc"])
               {
                  playerSlot = this.m_playersMC["player" + index.toString() + "_mc"] as MovieClip;
                  if(playerSlot.hasOwnProperty("checkmark_mc"))
                  {
                     this.m_playerCheckmarksMCs[index] = playerSlot["checkmark_mc"] as MovieClip;
                     this.m_playerCheckmarksMCs[index].visible = false;
                  }
                  if(playerSlot.hasOwnProperty("invite_bt"))
                  {
                     this.m_playerSelectBTs[index] = new FarmAnimatedTextButton(playerSlot["invite_bt"],"Select",this.onSelectFriendButtonClick(index));
                     this.m_playerSelectBTs[index].visible = true;
                  }
                  if(playerSlot.hasOwnProperty("icon_mc"))
                  {
                     this.m_playerIcons[index] = new FarmIcon(playerSlot["icon_mc"]);
                     this.m_playerIcons[index].visible = true;
                  }
                  if(playerSlot.hasOwnProperty("body_tf"))
                  {
                     this.m_playerNameTFs[index] = new ZwTextField(playerSlot["body_tf"],"name " + index.toString()) as ZwTextField;
                     this.m_playerNameTFs[index].visible = true;
                  }
                  playerSlot.visible = false;
                  this.m_playerSlots.push(playerSlot);
                  index++;
               }
               this.m_numFriendSlots = index;
               if(m_window.mainWindow.players_mc["searchBar_mc"])
               {
                  this.m_searchBarMC = addWidget(new ZwWidget(m_window.mainWindow.players_mc.searchBar_mc)) as ZwWidget;
                  if(this.m_searchBarMC.element.searchField_tf)
                  {
                     this.m_searchFieldTF = addWidget(new ZwTextField(this.m_searchBarMC.element.searchField_tf,DEFAULT_SEARCH_TEXT)) as ZwTextField;
                     this.m_searchFieldTF.visible = true;
                     m_window.mainWindow.players_mc.searchBar_mc.searchField_tf.addEventListener(MouseEvent.CLICK,this.onSearchTextButtonClick);
                     this.m_searchFieldInputBatcher = new EventBatcher(m_window.mainWindow.players_mc.searchBar_mc.searchField_tf,KeyboardEvent.KEY_UP,SEARCH_INPUT_BATCHING_MIN_DELAY,SEARCH_INPUT_BATCHING_MAX_DELAY);
                     this.m_searchFieldInputBatcher.addEventListener(EventBatchEvent.EVENT_BATCH,this.onKeyUpBatchHandler);
                  }
                  if(this.m_searchBarMC.element.clearsearch_bt)
                  {
                     this.m_clearSearchBT = addWidget(new FarmAnimatedButton(this.m_searchBarMC.element.clearsearch_bt,this.onClearSearchButtonClick)) as FarmAnimatedButton;
                     this.m_clearSearchBT.visible = false;
                  }
                  if(this.m_searchBarMC.element.search_mc)
                  {
                     this.m_searchMC = addWidget(new ZwWidget(this.m_searchBarMC.element.search_mc)) as ZwWidget;
                     this.m_searchMC.visible = true;
                  }
                  this.m_searchBarMC.visible = true;
               }
               if(m_window.mainWindow.players_mc["accept_bt"])
               {
                  this.m_playerAcceptBT = new FarmAnimatedTextButton(m_window.mainWindow.players_mc["accept_bt"],"Continue",this.onConfirmFriendButtonClick);
                  this.m_playerAcceptBT.visible = true;
                  this.m_playerAcceptBT.enabled = true;
               }
               if(m_window.mainWindow.players_mc["back_bt"])
               {
                  this.m_playerPrevPageBT = addWidget(new ZwButton(m_window.mainWindow.players_mc["back_bt"],this.onPrevPageButtonClick)) as ZwButton;
                  this.m_playerPrevPageBT.visible = false;
               }
               if(m_window.mainWindow.players_mc["next_bt"])
               {
                  this.m_playerNextPageBT = addWidget(new ZwButton(m_window.mainWindow.players_mc["next_bt"],this.onNextPageButtonClick)) as ZwButton;
                  this.m_playerNextPageBT.visible = false;
               }
               if(m_window.mainWindow.players_mc["page_tf"])
               {
                  this.m_playerPageTF = addWidget(new ZwTextField(m_window.mainWindow.players_mc["page_tf"],"1")) as ZwTextField;
                  this.m_playerPageTF.visible = false;
               }
               this.m_playersMC.visible = false;
            }
            if(m_window.mainWindow["friend_mc"])
            {
               this.m_friendMC = m_window.mainWindow["friend_mc"] as MovieClip;
               if(m_window.mainWindow.friend_mc["choose_bt"])
               {
                  this.m_openFriendsFrameBT = new FarmAnimatedTextButton(m_window.mainWindow.friend_mc["choose_bt"],"Loading...",this.onOpenFriendsFrameButtonClick);
                  this.m_openFriendsFrameBT.visible = true;
                  this.m_openFriendsFrameBT.enabled = false;
               }
               if(m_window.mainWindow.friend_mc["name_tf"])
               {
                  this.m_friendTF = addWidget(new ZwTextField(m_window.mainWindow.friend_mc["name_tf"],"Select friend")) as ZwTextField;
                  this.m_friendTF.visible = true;
               }
               if(m_window.mainWindow.friend_mc["icon_mc"])
               {
                  addWidget(this.m_friendIconMC = new FarmIcon(m_window.mainWindow.friend_mc["icon_mc"]));
                  this.m_friendIconMC.visible = true;
               }
               this.m_friendMC.visible = true;
            }
            if(m_window.mainWindow["gift_mc"])
            {
               this.m_giftMC = m_window.mainWindow["gift_mc"] as MovieClip;
               if(m_window.mainWindow.gift_mc["accept_bt"])
               {
                  this.m_giftAcceptBT = new FarmAnimatedTextButton(m_window.mainWindow.gift_mc["accept_bt"],"Continue",this.onConfirmGiftButtonClick);
                  this.m_giftAcceptBT.visible = true;
                  this.m_giftAcceptBT.enabled = true;
               }
               index = 0;
               while(this.m_giftMC["gift" + index.toString() + "_mc"])
               {
                  if(index >= GIFTS.length)
                  {
                     break;
                  }
                  giftItem = Global.farmGameSettingsManager.getFarmItemByName(GIFTS[index]);
                  giftSlot = this.m_giftMC["gift" + index.toString() + "_mc"] as MovieClip;
                  if(!giftItem)
                  {
                     break;
                  }
                  if(giftSlot.hasOwnProperty("checkmark_mc"))
                  {
                     this.m_giftCheckmarksMCs[index] = giftSlot["checkmark_mc"] as MovieClip;
                     this.m_giftCheckmarksMCs[index].visible = false;
                  }
                  if(giftSlot.hasOwnProperty("invite_bt"))
                  {
                     this.m_giftSelectBTs[index] = new FarmAnimatedTextButton(giftSlot["invite_bt"],"Select",this.onSelectGiftButtonClick(index));
                     this.m_giftSelectBTs[index].visible = true;
                  }
                  if(giftSlot.hasOwnProperty("icon_mc"))
                  {
                     this.m_giftIcons[index] = new FarmIcon(giftSlot["icon_mc"]);
                     this.m_giftIcons[index].loadIcon(giftItem.icon);
                     this.m_giftIcons[index].setIconSize(50,50);
                     this.m_giftIcons[index].setSmoothing(true);
                     this.m_giftIcons[index].visible = true;
                  }
                  giftSlot.visible = true;
                  index++;
               }
               this.m_giftMC.visible = false;
            }
            if(m_window.mainWindow["giftit_mc"])
            {
               this.m_giftitMC = m_window.mainWindow["giftit_mc"] as MovieClip;
               if(m_window.mainWindow.giftit_mc["choose_bt"])
               {
                  this.m_openGiftsFrameBT = new FarmAnimatedTextButton(m_window.mainWindow.giftit_mc["choose_bt"],"Select",this.onOpenGiftsFrameButtonClick);
                  this.m_openGiftsFrameBT.visible = true;
               }
               if(m_window.mainWindow.giftit_mc["gift_tf"])
               {
                  this.m_giftTF = addWidget(new ZwTextField(m_window.mainWindow.giftit_mc["gift_tf"],"Select gift")) as ZwTextField;
                  this.m_giftTF.visible = true;
               }
               if(m_window.mainWindow.giftit_mc["icon_mc"])
               {
                  this.m_giftIconMC = new FarmIcon(m_window.mainWindow.giftit_mc["icon_mc"]);
                  this.m_giftIconMC.visible = true;
               }
               this.m_giftitMC.visible = true;
            }
            if(m_window.mainWindow.hasOwnProperty("close_bt"))
            {
               m_closeButton = addWidget(new FarmButton(m_window.mainWindow.close_bt,onClose)) as FarmButton;
               m_closeButton.visible = false;
            }
            if(m_window.mainWindow["accept_bt"])
            {
               m_accept_bt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,"Send!",this.onAccept)) as FarmAnimatedTextButton;
               m_accept_bt.enabled = false;
            }
         }
         this.getAppFriendsData();
      }
      
      override public function refreshWindow() : void
      {
         if(Boolean(this.m_selectedGift) && Boolean(this.m_giftTF) && Boolean(this.m_giftIconMC))
         {
            this.m_giftTF.text = this.m_selectedGift.friendlyTitle;
            this.m_giftIconMC.loadIcon(this.m_selectedGift.icon);
            this.m_giftIconMC.fitIconInsideBounds(100,100);
            this.m_giftIconMC.setSmoothing(true);
         }
         if(Boolean(this.m_selectedMessage) && Boolean(this.m_bodyTF))
         {
            this.m_bodyTF.text = this.m_selectedMessage;
         }
         if(Boolean(this.m_selectedFriend) && Boolean(this.m_friendTF) && Boolean(this.m_friendIconMC))
         {
            this.m_friendTF.text = this.m_selectedFriend.name;
            this.m_friendIconMC.loadIcon(this.m_selectedFriend.pic_square);
            this.m_friendIconMC.fitIconInsideBounds(100,100);
            this.m_friendIconMC.setSmoothing(true);
         }
         m_accept_bt.enabled = Boolean(this.m_selectedGift) && Boolean(this.m_selectedMessage) && Boolean(this.m_selectedFriend);
      }
      
      private function onKeyUpBatchHandler(event:EventBatchEvent) : void
      {
         if(this.m_searchFieldTF.text == "")
         {
            this.onClearSearchButtonClick(event);
            return;
         }
         this.m_friendsToShow = this.m_allFriends.filter(function(friend:*, index:int, array:Array):Boolean
         {
            return Boolean(friend) && friend.name.toLowerCase().search(m_searchFieldTF.text.toLowerCase()) != -1;
         });
         this.populateFriendSlots();
      }
      
      private function toggleOverlayVisibility() : void
      {
         if(this.m_overlayMC)
         {
            this.m_overlayMC.visible = !this.m_overlayMC.visible;
         }
      }
      
      private function onOpenMessageFrameButtonClick(event:Event) : void
      {
         if(this.m_selectMC)
         {
            this.m_selectMC.visible = true;
         }
         this.toggleOverlayVisibility();
      }
      
      private function onSelectMessageButtonClick(index:int) : Function
      {
         return function(event:Event):void
         {
            if(index < MESSAGES.length)
            {
               m_selectedMessage = MESSAGES[index];
            }
            for(var i:* = 0; i < m_messageCheckmarksMCs.length; i++)
            {
               if(m_messageCheckmarksMCs[i])
               {
                  m_messageCheckmarksMCs[i].visible = i == index;
               }
            }
         };
      }
      
      private function onConfirmMessageButtonClick(event:Event) : void
      {
         if(this.m_selectMC)
         {
            this.m_selectMC.visible = false;
         }
         this.refreshWindow();
         this.toggleOverlayVisibility();
      }
      
      private function onOpenGiftsFrameButtonClick(event:Event) : void
      {
         if(this.m_giftMC)
         {
            this.m_giftMC.visible = true;
         }
         this.toggleOverlayVisibility();
      }
      
      private function onSelectGiftButtonClick(index:int) : Function
      {
         return function(event:Event):void
         {
            if(index < GIFTS.length)
            {
               m_selectedGift = Global.farmGameSettingsManager.getFarmItemByName(GIFTS[index]);
            }
            for(var i:* = 0; i < m_giftCheckmarksMCs.length; i++)
            {
               if(m_giftCheckmarksMCs[i])
               {
                  m_giftCheckmarksMCs[i].visible = i == index;
               }
            }
         };
      }
      
      private function onConfirmGiftButtonClick(event:Event) : void
      {
         if(this.m_giftMC)
         {
            this.m_giftMC.visible = false;
         }
         this.refreshWindow();
         this.toggleOverlayVisibility();
      }
      
      private function hasNextPage() : Boolean
      {
         return this.m_friendsToShow.length - (this.m_currentPage * this.m_numFriendSlots + 1) >= 0;
      }
      
      private function hasPrevPage() : Boolean
      {
         return this.m_currentPage > 1;
      }
      
      private function getFormattedName(name:String) : String
      {
         return name.split(" ").map(function(namePart:String, index:int, array:Array):String
         {
            if(index == 0)
            {
               return namePart;
            }
            return namePart.charAt(0) + ".";
         }).join(" ");
      }
      
      private function populateFriendSlots() : void
      {
         var friend:Object = null;
         var numFriends:Number = this.m_friendsToShow.length;
         if(numFriends <= this.m_numFriendSlots)
         {
            this.m_currentPage = 1;
         }
         var pageStartIndex:Number = (this.m_currentPage - 1) * this.m_numFriendSlots;
         this.m_playerPageTF.text = this.m_currentPage.toString();
         this.m_numFriendSlotsToShow = Math.min(numFriends - pageStartIndex,this.m_numFriendSlots);
         for(var i:int = 0; i < this.m_numFriendSlots; i++)
         {
            friend = this.m_friendsToShow[pageStartIndex + i];
            this.m_playerSlots[i].visible = i < this.m_numFriendSlotsToShow;
            if(i < this.m_numFriendSlotsToShow)
            {
               if(this.m_playerNameTFs[i])
               {
                  this.m_playerNameTFs[i].text = this.getFormattedName(friend.name);
               }
               if(this.m_playerIcons[i])
               {
                  this.m_playerIcons[i].loadIcon(friend.pic_square);
                  this.m_playerIcons[i].setIconSize(50,50);
                  this.m_playerIcons[i].setSmoothing(true);
                  this.m_playerIcons[i].visible = true;
               }
            }
         }
         this.updateSelectedFriendCheckmark();
         if(this.m_playerNextPageBT)
         {
            this.m_playerNextPageBT.visible = this.hasNextPage();
         }
         if(this.m_playerPrevPageBT)
         {
            this.m_playerPrevPageBT.visible = this.hasPrevPage();
         }
      }
      
      public function getAppFriendsData() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction("GuildService","getFriendsData",this.onGetFriendsData,["FVGuild"]),true);
      }
      
      public function onGetFriendsData(friends:Object) : void
      {
         if(friends)
         {
            this.m_openFriendsFrameBT.enabled = true;
            this.m_openFriendsFrameBT.text = "Select";
            this.m_allFriends = this.m_friendsToShow = friends.data;
            this.populateFriendSlots();
         }
         m_closeButton.visible = true;
      }
      
      private function onOpenFriendsFrameButtonClick(event:Event) : void
      {
         if(this.m_playersMC)
         {
            this.m_playersMC.visible = true;
         }
         this.toggleOverlayVisibility();
      }
      
      private function updateSelectedFriendCheckmark() : void
      {
         var selectedFriendIndex:Number = this.m_friendsToShow.indexOf(this.m_selectedFriend) % this.m_numFriendSlots;
         var selectedFriendPage:Number = int(this.m_friendsToShow.indexOf(this.m_selectedFriend) / this.m_numFriendSlots) + 1;
         for(var i:int = 0; i < this.m_numFriendSlotsToShow; i++)
         {
            if(this.m_playerCheckmarksMCs[i])
            {
               this.m_playerCheckmarksMCs[i].visible = i == selectedFriendIndex && this.m_currentPage == selectedFriendPage;
            }
         }
      }
      
      private function onSelectFriendButtonClick(index:int) : Function
      {
         return function(event:Event):void
         {
            if(m_currentPage + index - 1 < m_friendsToShow.length)
            {
               m_selectedFriend = m_friendsToShow[(m_currentPage - 1) * m_numFriendSlots + index];
            }
            updateSelectedFriendCheckmark();
         };
      }
      
      private function onConfirmFriendButtonClick(event:Event) : void
      {
         if(this.m_playersMC)
         {
            this.m_playersMC.visible = false;
         }
         this.refreshWindow();
         this.toggleOverlayVisibility();
      }
      
      private function onPrevPageButtonClick(event:Event) : void
      {
         if(this.hasPrevPage())
         {
            --this.m_currentPage;
            this.populateFriendSlots();
         }
      }
      
      private function onNextPageButtonClick(event:Event) : void
      {
         if(this.hasNextPage())
         {
            ++this.m_currentPage;
            this.populateFriendSlots();
         }
      }
      
      private function canClearSearchText() : Boolean
      {
         return Boolean(this.m_searchFieldTF) && this.m_searchFieldTF.text == DEFAULT_SEARCH_TEXT;
      }
      
      private function clearSearchText() : void
      {
         if(this.m_searchFieldTF)
         {
            this.m_searchFieldTF.text = "";
         }
      }
      
      private function onSearchTextButtonClick(event:MouseEvent) : void
      {
         if(this.m_searchMC)
         {
            this.m_searchMC.visible = false;
         }
         if(this.m_clearSearchBT)
         {
            this.m_clearSearchBT.visible = true;
         }
         if(this.canClearSearchText())
         {
            this.clearSearchText();
         }
      }
      
      private function onClearSearchButtonClick(event:Event) : void
      {
         this.m_friendsToShow = this.m_allFriends;
         this.clearSearchText();
         this.populateFriendSlots();
      }
      
      private function closeMOTD(event:MouseEvent) : void
      {
         m_accept_bt.text = "Send!";
         super.onAccept(event);
         var popup:GenericPopupTitle = new GenericPopupTitle("Hurray!","Your gift is on the way to your friend.",true);
         popup.setAcceptTextName("Awesome");
         UI.displayPopup(popup,false);
      }
      
      private function onSendGiftTransactionComplete(event:MouseEvent) : Function
      {
         return function(result:Object):void
         {
            closeMOTD(event);
         };
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         if(!this.m_selectedFriend || !this.m_selectedGift || !this.m_selectedMessage)
         {
            return;
         }
         FarmStatsManager.count("FVAnniversaryV10","birthday_card",String(this.m_selectedFriend.uid),this.m_selectedMessage,this.m_selectedGift.friendlyTitle,Global.worldManager.currentWorldType,SENT);
         m_accept_bt.text = "Sending...";
         m_accept_bt.enabled = false;
         TransactionManager.addTransaction(new TGenericTransaction("FVV10AnniversaryBirthdayCardService","setGiftForUser",this.onSendGiftTransactionComplete(event),[String(this.m_selectedFriend.uid),this.m_selectedMessage,this.m_selectedGift.name]));
      }
   }
}

