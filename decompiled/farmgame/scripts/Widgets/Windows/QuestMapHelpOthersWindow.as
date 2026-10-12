package Widgets.Windows
{
   import Classes.Quest.FarmQuest;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.HelpFriendFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class QuestMapHelpOthersWindow extends FarmWindow
   {
      
      protected static const VERTICAL_OFFSET:int = -33;
      
      protected static const ICON_COMMON_PATH:String = "assets/dialogs/FV_Support/FV_QuestMap/";
      
      protected static const POPUP_NAME:String = "questMapHelpOthersWindow";
      
      protected var m_questChain:String = null;
      
      protected var m_playerQuest:FarmQuest;
      
      protected var m_locationIndex:int = 0;
      
      protected var m_friends:Array;
      
      protected var m_currentPage:int = 0;
      
      protected var m_friendsPerPage:int;
      
      protected var m_onFriendHelpClick:Function;
      
      protected var m_title:ZwTextField;
      
      protected var m_location:ZwTextField;
      
      protected var m_pages:ZwTextField;
      
      protected var m_icon:FarmIcon;
      
      protected var m_helpFriendFrames:Array;
      
      protected var m_pageLeft:FarmAnimatedButton;
      
      protected var m_pageRight:FarmAnimatedButton;
      
      public function QuestMapHelpOthersWindow(windowAssetRelUrl:String, onFriendHelpClick:Function, modal:Boolean = true, bAddClickBlocker:Boolean = false, questChain:String = "")
      {
         super(windowAssetRelUrl,modal,bAddClickBlocker);
         this.name = POPUP_NAME;
         this.m_questChain = questChain;
         this.m_onFriendHelpClick = onFriendHelpClick;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.m_title = new ZwTextField(m_window.title_tf,"title",true);
         this.m_location = new ZwTextField(m_window.location_tf,"location");
         this.m_pages = new ZwTextField(m_window.page_tf,"blank of blank");
         this.m_icon = new FarmIcon(m_window.icon_mc);
         this.m_pageLeft = new FarmAnimatedButton(m_window.arrowLeft_mc,this.onPageLeft);
         this.m_pageRight = new FarmAnimatedButton(m_window.arrowRight_mc,this.onPageRight);
         addWidget(this.m_title);
         addWidget(this.m_location);
         addWidget(this.m_pages);
         addWidget(this.m_icon);
         addWidget(this.m_pageLeft);
         addWidget(this.m_pageRight);
         var i:int = 1;
         this.m_helpFriendFrames = [];
         var falseClass:Class = m_window.loaderInfo.applicationDomain.getDefinition("HelpFalseOthersMC") as Class;
         var trueClass:Class = m_window.loaderInfo.applicationDomain.getDefinition("HelpTrueOthersMC") as Class;
         while(m_window["anchor" + i + "_mc"] != null)
         {
            this.m_helpFriendFrames.push(new HelpFriendFrame(new trueClass(),new falseClass(),this.m_onFriendHelpClick));
            addWidget(this.m_helpFriendFrames[i - 1] as HelpFriendFrame);
            (m_window["anchor" + i + "_mc"] as MovieClip).visible = true;
            (m_window["anchor" + i + "_mc"] as MovieClip).addChild((this.m_helpFriendFrames[i - 1] as HelpFriendFrame).element as Sprite);
            i++;
         }
         this.m_friendsPerPage = i - 1;
         this.setup();
      }
      
      override protected function onClose(event:Event) : void
      {
         this.hide();
      }
      
      public function setLocation(location:int, friends:Array, playerQuest:FarmQuest) : void
      {
         this.m_friends = friends;
         this.m_locationIndex = location;
         this.m_playerQuest = playerQuest;
         this.setup();
      }
      
      protected function setup() : void
      {
         if(m_isLoaded && this.m_friends != null)
         {
            if(this.m_playerQuest == null || this.m_playerQuest.location >= this.m_locationIndex)
            {
               this.m_icon.loadIcon(ICON_COMMON_PATH + this.m_questChain + "_shown_" + this.m_locationIndex + ".png");
            }
            else
            {
               this.m_icon.loadIcon(ICON_COMMON_PATH + this.m_questChain + "_hidden_" + this.m_locationIndex + ".png");
            }
            this.m_icon.visible = true;
            this.m_title.text = ZLocUtils.t("Dialogs",this.m_questChain + "_QuestMapOthers_Title",{"quantity":this.m_friends.length});
            this.m_title.visible = true;
            this.m_location.text = ZLocUtils.t("Quests",this.m_questChain + "_location_" + (this.m_locationIndex + 1));
            this.m_location.visible = true;
            this.setPage(0);
         }
      }
      
      protected function setPage(newPage:int) : void
      {
         var slot:int = 0;
         var friendInd:int = 0;
         this.m_currentPage = newPage;
         if(this.m_pages)
         {
            this.m_pages.text = ZLocUtils.t("Dialogs","QuestMapOthers_Pages",{
               "quantity":newPage + 1,
               "maximum":Math.floor((this.m_friends.length - 1) / this.m_friendsPerPage) + 1
            });
            this.m_pages.visible = true;
         }
         var offset:int = this.m_currentPage * this.m_friendsPerPage;
         for(slot = 0; slot < this.m_friendsPerPage; slot++)
         {
            friendInd = slot + offset;
            if(friendInd < this.m_friends.length)
            {
               (this.m_helpFriendFrames[slot] as HelpFriendFrame).visible = true;
               (this.m_helpFriendFrames[slot] as HelpFriendFrame).setupForQuestHelp(this.m_friends[friendInd],this.m_questChain,this.m_playerQuest);
            }
            else
            {
               (this.m_helpFriendFrames[slot] as HelpFriendFrame).visible = false;
            }
         }
         if(this.m_currentPage == 0)
         {
            this.m_pageLeft.visible = false;
         }
         else
         {
            this.m_pageLeft.visible = true;
         }
         if(Math.floor((this.m_friends.length - 1) / this.m_friendsPerPage) <= this.m_currentPage)
         {
            this.m_pageRight.visible = false;
         }
         else
         {
            this.m_pageRight.visible = true;
         }
      }
      
      protected function onPageLeft(event:Event) : void
      {
         if(this.m_currentPage > 0)
         {
            this.setPage(this.m_currentPage - 1);
         }
      }
      
      protected function onPageRight(event:Event) : void
      {
         if(this.m_currentPage < Math.floor(this.m_friends.length / this.m_friendsPerPage))
         {
            this.setPage(this.m_currentPage + 1);
         }
      }
      
      override public function getDialogOffset() : Point
      {
         return new Point(0,VERTICAL_OFFSET);
      }
   }
}

