package Widgets.Windows
{
   import Managers.GuildManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GuildAcceptJoinRequestSlotFrame;
   import Widgets.Frames.GuildInviteFriendSlotFrame;
   import Widgets.Frames.TabMenu;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class GuildAddMembersWindow extends FarmWindow
   {
      
      private var m_featureName:String;
      
      private const TITLE_TF:String = "title_tf";
      
      private var m_inviteFriendSlotFrame:GuildInviteFriendSlotFrame;
      
      private var m_leadershipStatus:Boolean = false;
      
      private var m_joinAcceptRequestSlotFrame:GuildAcceptJoinRequestSlotFrame;
      
      private var m_tab1_bt:FarmAnimatedButton;
      
      private var m_tab2_bt:FarmAnimatedButton;
      
      private var m_tabMenu:TabMenu;
      
      private var m_loader_mc:MovieClip;
      
      private var m_message_tf:ZwTextField;
      
      public function GuildAddMembersWindow(featureName:String, assetPath:String, leadershipStatus:Boolean)
      {
         this.m_featureName = featureName;
         this.m_leadershipStatus = leadershipStatus;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var pendoingApprovalCount:int = 0;
         var disabledDealTypes:Dictionary = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Add Clan Members"));
         }
         var defaultTabNum:int = 0;
         if(this.m_leadershipStatus)
         {
            pendoingApprovalCount = GuildManager.getInstance().getJoinRequestsCount();
            if(pendoingApprovalCount > 0)
            {
               defaultTabNum = 1;
            }
            this.m_tabMenu = new TabMenu(m_window,2,defaultTabNum,this.onTabClick,"tab","_bt",null);
         }
         else
         {
            disabledDealTypes = new Dictionary();
            disabledDealTypes["1"] = true;
            this.m_tabMenu = new TabMenu(m_window,2,0,this.onTabClick,"tab","_bt",disabledDealTypes);
         }
         if(m_window.hasOwnProperty("players_mc"))
         {
            this.m_inviteFriendSlotFrame = new GuildInviteFriendSlotFrame(m_window["players_mc"],this.m_featureName,this);
            this.m_inviteFriendSlotFrame.visible = true;
         }
         if(this.m_tabMenu)
         {
            this.m_tabMenu.setTabName(0,"Invite Friends");
            this.m_tabMenu.setTabName(1,"Accept Requests");
         }
         if(m_window.hasOwnProperty("loader_mc"))
         {
            this.m_loader_mc = m_window["loader_mc"] as MovieClip;
            this.m_loader_mc.visible = false;
         }
         addWidget(this.m_message_tf = new ZwTextField(m_window["message_tf"],""));
         this.onTabClick(defaultTabNum);
      }
      
      public function get selectedTab() : int
      {
         return this.m_tabMenu.selectedTab;
      }
      
      public function onTabClick(tabNum:int) : void
      {
         if(this.m_inviteFriendSlotFrame)
         {
            if(tabNum == 0)
            {
               this.m_inviteFriendSlotFrame.setupSlotData(GuildManager.getInstance().getFriendsDataForInvites());
               this.m_inviteFriendSlotFrame.refresh();
            }
            else
            {
               this.m_inviteFriendSlotFrame.setupSlotData(GuildManager.getInstance().getJoinRequestsData());
               this.m_inviteFriendSlotFrame.refresh();
            }
         }
      }
      
      override public function close() : void
      {
         super.close();
         GuildManager.getInstance().m_guildMainWindow = null;
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         GuildManager.getInstance().openGuildViewWindow();
      }
   }
}

