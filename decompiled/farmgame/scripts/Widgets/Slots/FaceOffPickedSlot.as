package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FaceOffManager;
   import Managers.FarmGameSettingsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FaceOffWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class FaceOffPickedSlot extends ZwSlotFrame
   {
      
      public static const DEFAULT_TRANSACTION_SERVICE:String = "FaceOffService";
      
      private var m_item:FarmItem;
      
      private var m_minutesToVote:int;
      
      private var m_window:FaceOffWindow;
      
      private var m_voteButton:FarmAnimatedButton;
      
      private var m_facePiles:Array;
      
      private var m_facePileVariant:int;
      
      private var m_resultsShowVariant:int;
      
      public function FaceOffPickedSlot(element:MovieClip, itemName:String, window:FaceOffWindow)
      {
         super(element);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            this.m_item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         }
         else
         {
            this.m_item = new FarmItem(Global.farmGameSettingsManager.getItemXMLByName(itemName));
         }
         this.m_window = window;
         this.m_facePileVariant = Global.experimentManager.getExperimentVariant("fv_face_off_facepile");
         this.m_resultsShowVariant = Global.experimentManager.getExperimentVariant("fv_face_off_results_show");
         this.m_minutesToVote = FaceOffManager.getInstance().getVoteInterval() * 1000 + FaceOffManager.getInstance().getLastVoteTime() - GlobalEngine.serverTime;
         this.m_minutesToVote = this.m_minutesToVote / 1000 / 60;
         if(m_element["back_mc"])
         {
            addWidget(new ZwBaseWidget(m_element.back_mc));
         }
         if(Boolean(m_element["image_mc"]) && Boolean(this.m_item))
         {
            addWidget(new ObjectPreviewFrame(m_element.image_mc,this.m_item));
         }
         if(Boolean(m_element["imageBitmap_mc"]) && Boolean(this.m_item))
         {
            addWidget(new ObjectPreviewFrame(m_element.imageBitmap_mc,this.m_item));
         }
         if(Boolean(m_element["itemTitle_tf"]) && Boolean(this.m_item))
         {
            addWidget(new ZwTextField(m_element.itemTitle_tf,ZLocUtils.tk_pk_asTitle(this.m_item.friendlyName)));
         }
         if(m_element["vote_tf"])
         {
            addWidget(new ZwTextField(m_element.vote_tf,""));
         }
         if(Boolean(m_element["voteCopy_tf"]) && this.m_resultsShowVariant != 3)
         {
            addWidget(new ZwTextField(m_element.voteCopy_tf,ZLocUtils.t("Dialogs","FaceOffGeneric_SubVote")));
         }
         if(m_element["friendsVoted_tf"])
         {
            addWidget(new ZwTextField(m_element.friendsVoted_tf,""));
         }
         if(Boolean(m_element["buy_bt"]) && Boolean(this.m_item))
         {
            (m_element.buy_bt["cost_tf"] as TextField).text = this.m_item.cash.toString();
            addWidget(new FarmAnimatedButton(m_element.buy_bt,this.buyButtonClicked));
         }
         if(m_element["face_0_mc"])
         {
            addWidget(new FarmIcon(m_element.face_0_mc));
         }
         if(m_element["face_1_mc"])
         {
            addWidget(new FarmIcon(m_element.face_1_mc));
         }
         if(m_element["face_2_mc"])
         {
            addWidget(new FarmIcon(m_element.face_2_mc));
         }
         if(m_element["vote_bt"])
         {
            this.m_voteButton = new FarmAnimatedButton(m_element.vote_bt,this.voteButtonClicked);
            if(this.m_minutesToVote > 0)
            {
               this.m_voteButton.enabled = false;
               if(this.m_voteButton["element"]["generic_tf"])
               {
                  (this.m_voteButton["element"]["generic_tf"] as TextField).text = ZLocUtils.t("Dialogs","FaceOffGeneric_TimeToVote",{"timeToVote":this.m_minutesToVote});
               }
            }
            else
            {
               this.m_voteButton.enabled = true;
               if(this.m_voteButton["element"]["generic_tf"])
               {
                  (this.m_voteButton["element"]["generic_tf"] as TextField).text = ZLocUtils.t("Dialogs","FaceOffGeneric_VoteText");
               }
            }
            addWidget(this.m_voteButton);
         }
      }
      
      public function toggleResultsMessage(on:Boolean) : void
      {
         if(on)
         {
            if(Boolean(m_element["voteCopy_tf"]) && this.m_resultsShowVariant != 3)
            {
               getWidget(m_element["voteCopy_tf"]).visible = true;
            }
         }
         else if(Boolean(m_element["voteCopy_tf"]) && this.m_resultsShowVariant != 3)
         {
            getWidget(m_element["voteCopy_tf"]).visible = false;
         }
      }
      
      public function updateItem(item:String) : void
      {
         var i:int = 0;
         var profilePic:FarmIcon = null;
         var newItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(item);
         if(Boolean(m_element) && Boolean(m_element.image_mc) && Boolean(getWidget(m_element.image_mc)))
         {
            removeWidget(m_element.image_mc);
            addWidget(new ObjectPreviewFrame(m_element.image_mc,newItem));
            this.m_item = newItem;
         }
         if(Boolean(m_element) && Boolean(m_element.imageBitmap_mc) && Boolean(getWidget(m_element.imageBitmap_mc)))
         {
            removeWidget(m_element.imageBitmap_mc);
            addWidget(new ObjectPreviewFrame(m_element.imageBitmap_mc,newItem));
            this.m_item = newItem;
         }
         var textField:ZwTextField = getWidget(m_element.itemTitle_tf) as ZwTextField;
         if(textField)
         {
            textField.text = ZLocUtils.tk_pk_asTitle(this.m_item.friendlyName);
         }
         if(this.m_item.type == "tree")
         {
            getWidget(m_element["imageBitmap_mc"]).visible = true;
            getWidget(m_element["image_mc"]).visible = false;
         }
         else
         {
            getWidget(m_element["imageBitmap_mc"]).visible = false;
            getWidget(m_element["image_mc"]).visible = true;
         }
         (getWidget(m_element.friendsVoted_tf) as ZwTextField).text = ZLocUtils.t("Dialogs","FaceOffGeneric_FriendsHelped",{"numVotes":FaceOffManager.getInstance().getNumberFriendVotes(FaceOffManager.getInstance().itemToStage(item))});
         this.m_minutesToVote = FaceOffManager.getInstance().getVoteInterval() + FaceOffManager.getInstance().getLastVoteTime() - GlobalEngine.serverTime / 1000;
         this.m_minutesToVote /= 60;
         if(this.m_minutesToVote <= 0)
         {
            this.m_voteButton = getWidget(this.m_voteButton) as FarmAnimatedButton;
            this.m_voteButton.enabled = true;
            if(Boolean(this.m_voteButton["element"]["generic_tf"]) && Boolean(FaceOffManager.getInstance().getStagePicked(FaceOffManager.getInstance().getCurrentStage())))
            {
               (this.m_voteButton["element"]["generic_tf"] as TextField).text = "Ask for Votes";
            }
            else if(this.m_voteButton["element"]["generic_tf"])
            {
               (this.m_voteButton["element"]["generic_tf"] as TextField).text = ZLocUtils.t("Dialogs","FaceOffGeneric_VoteText");
            }
         }
         else
         {
            (this.m_voteButton["element"]["generic_tf"] as TextField).text = ZLocUtils.t("Dialogs","FaceOffGeneric_TimeToVote",{"timeToVote":this.m_minutesToVote});
            this.m_voteButton.enabled = false;
         }
         if(m_element.buy_bt["cost_tf"])
         {
            (m_element.buy_bt["cost_tf"] as TextField).text = this.m_item.cash.toString();
         }
         this.m_facePiles = Global.friendManager.getFriendObjects(FaceOffManager.getInstance().getFacePiles(this.m_item.name));
         if(this.m_facePiles)
         {
            i = 0;
            while(i < this.m_facePiles.length && Boolean(m_element["face_" + i.toString() + "_mc"]))
            {
               profilePic = getWidget(m_element["face_" + i.toString() + "_mc"]) as FarmIcon;
               if(Boolean(profilePic) && Boolean(this.m_facePiles[i]))
               {
                  (getWidget(profilePic) as FarmIcon).loadIcon(this.m_facePiles[i].picture);
               }
               i++;
            }
         }
         if(this.m_facePileVariant == 2)
         {
            if(this.m_facePiles.length == 0)
            {
               getWidget(m_element.face_0_mc).visible = false;
               getWidget(m_element.face_1_mc).visible = false;
               getWidget(m_element.face_2_mc).visible = false;
            }
            else if(this.m_facePiles.length == 1)
            {
               getWidget(m_element.face_0_mc).visible = true;
               getWidget(m_element.face_1_mc).visible = false;
               getWidget(m_element.face_2_mc).visible = false;
            }
            else if(this.m_facePiles.length == 2)
            {
               getWidget(m_element.face_0_mc).visible = true;
               getWidget(m_element.face_1_mc).visible = false;
               getWidget(m_element.face_2_mc).visible = true;
            }
            else if(this.m_facePiles.length == 3)
            {
               getWidget(m_element.face_0_mc).visible = true;
               getWidget(m_element.face_1_mc).visible = true;
               getWidget(m_element.face_2_mc).visible = true;
            }
         }
         else
         {
            getWidget(m_element.face_0_mc).visible = false;
            getWidget(m_element.face_1_mc).visible = false;
            getWidget(m_element.face_2_mc).visible = false;
         }
      }
      
      public function getItemName() : String
      {
         return this.m_item.name;
      }
      
      public function toggleVotingButton(on:Boolean) : void
      {
         if(on)
         {
            this.m_voteButton.enabled = true;
            if(this.m_voteButton["element"]["generic_tf"])
            {
               (this.m_voteButton["element"]["generic_tf"] as TextField).text = "Vote and Ask";
            }
         }
         else if(this.m_voteButton["element"]["generic_tf"])
         {
            (this.m_voteButton["element"]["generic_tf"] as TextField).text = "Voting Over";
            this.m_voteButton.enabled = false;
         }
      }
      
      public function buyButtonClicked(event:Event) : void
      {
         if(Global.player.cash >= this.m_item.cash)
         {
            TransactionManager.addTransaction(new TGenericTransaction(DEFAULT_TRANSACTION_SERVICE,"buyFaceOffItem",this.buyButtonTransactionComplete,[this.m_item.name]));
            Global.player.cash -= this.m_item.cash;
            Global.player.addGift(this.m_item.name);
            this.m_item.onUse();
            this.m_window.close();
         }
         else
         {
            UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",this.m_item.cash,this.m_item.type);
         }
      }
      
      public function buyButtonTransactionComplete(evet:Event) : void
      {
      }
      
      public function setVoteText(text:String) : void
      {
         (getWidget(m_element.vote_tf) as ZwTextField).text = text;
      }
      
      public function voteButtonClicked(event:Event) : void
      {
         if(m_element["vote_bt"])
         {
            FaceOffManager.getInstance().vote(this.m_item.name);
            this.m_window.update();
         }
      }
   }
}

