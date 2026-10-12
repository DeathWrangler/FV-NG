package Widgets.Windows.NeighborPlumbing
{
   import Classes.Friend;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TNeighborPlumbingSeenFriend;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.events.MouseEvent;
   
   public class AddSpecificNeighborWindow extends FarmWindow
   {
      
      private static var numTimesWindowDisplayed:uint = 0;
      
      private var m_friendToAdd:Friend = null;
      
      private var m_commChannelExperimentVariant:int = 0;
      
      public function AddSpecificNeighborWindow(friendToAdd:Friend)
      {
         super("assets/dialogs/FV_FriendSuggest.swf");
         this.m_friendToAdd = friendToAdd;
      }
      
      override protected function postLoadComplete() : void
      {
         var promptStr:String = null;
         var acceptStr:String = null;
         var trackingStr:String = null;
         numTimesWindowDisplayed += 1;
         this.m_commChannelExperimentVariant = 1;
         var friendIcon:String = "";
         var friendName:String = "";
         var friendFirstName:String = "";
         if(this.m_friendToAdd)
         {
            friendIcon = this.m_friendToAdd.picture;
            friendName = this.m_friendToAdd.name;
            friendFirstName = this.m_friendToAdd.firstName;
         }
         var titleStr:String = ZLocUtils.t("Dialogs","NeighborPlumbing_AddNeighbor_Title");
         var cancelStr:String = ZLocUtils.t("Dialogs","NeighborPlumbing_AddNeighbor_Button_Cancel");
         var gender:String = this.m_friendToAdd.snUser.gender;
         if(this.m_commChannelExperimentVariant > 0)
         {
            promptStr = ZLocUtils.t("Dialogs","NeighborPlumbing_AddNeighborWall_Prompt",{"user":ZLocUtils.tn(friendFirstName,ZLocUtils.tg(gender))});
            acceptStr = ZLocUtils.t("Dialogs","NeighborPlumbing_AddNeighbor_Button_Share");
            trackingStr = "w2wDialogImpressions";
         }
         else
         {
            promptStr = ZLocUtils.t("Dialogs","NeighborPlumbing_AddNeighborRequest_Prompt",{"user":ZLocUtils.tn(friendFirstName,ZLocUtils.tg(gender))});
            acceptStr = ZLocUtils.t("Dialogs","NeighborPlumbing_AddNeighbor_Button_Add_Neighbor");
            trackingStr = "requestDialogImpressions";
         }
         var mainFrame:ZwFrame = new ZwFrame(m_window.master_mc);
         addWidget(mainFrame);
         mainFrame.addWidget(new ZwTextField(m_window.master_mc.title_tf,titleStr));
         mainFrame.addWidget(new ZwTextField(m_window.master_mc.generic_tf,promptStr));
         mainFrame.addWidget(new FarmAnimatedTextButton(m_window.master_mc.accept_bt,acceptStr,this.onClickAccept));
         mainFrame.addWidget(new FarmAnimatedTextButton(m_window.master_mc.cancel_bt,cancelStr,this.onClickCancel));
         mainFrame.addWidget(new FarmIcon(m_window.master_mc.graphic_mc));
         mainFrame.addWidget(new FarmIcon(m_window.master_mc.profilePic_mc,friendIcon));
         mainFrame.addWidget(new ZwTextField(m_window.master_mc.name_tf,friendName));
         FarmStatsManager.count("addNeighborPrompts",trackingStr,"dialogView");
         Global.player.setFeatureLastShown("fv_add_neighbor_prompts",GlobalEngine.serverTime,true);
      }
      
      private function onClickAccept(event:MouseEvent) : void
      {
         this.finishAndClose(true);
      }
      
      private function onClickCancel(event:MouseEvent) : void
      {
         this.finishAndClose(false);
      }
      
      private function finishAndClose(isAccepted:Boolean) : void
      {
         var bundleId:String = null;
         var comboSuffix:String = "_0_" + numTimesWindowDisplayed;
         if(isAccepted)
         {
            if(this.m_commChannelExperimentVariant > 0)
            {
               FarmStatsManager.count("addNeighborPrompts","w2wDialogImpressions" + comboSuffix,"addNeighborClick" + comboSuffix);
               bundleId = "NeighborPlumbingAddW2W" + comboSuffix;
               TransactionManager.addTransaction(new TNeighborPlumbingSeenFriend(String(this.m_friendToAdd.uid),isAccepted,bundleId),true);
            }
            else
            {
               FarmStatsManager.count("addNeighborPrompts","requestDialogImpressions","addNeighborClick");
               GlobalEngine.socialNetwork.redirect("addspecificneighborprompt.php?friendId=" + this.m_friendToAdd.uid);
            }
         }
         else if(this.m_commChannelExperimentVariant > 0)
         {
            FarmStatsManager.count("addNeighborPrompts","w2wDialogImpressions" + comboSuffix,"noThanksClick" + comboSuffix);
         }
         else
         {
            FarmStatsManager.count("addNeighborPrompts","requestDialogImpressions","noThanksClick");
         }
         close();
      }
   }
}

