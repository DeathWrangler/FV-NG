package Widgets.Windows
{
   import Classes.IsraelInnovationCommunityGoalTask;
   import Display.HUD.HUD;
   import Managers.IsraelInnovationManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.IsraelInnovationCommunityGoalFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.Timer;
   
   public class IsraelInnovationCommunityGoalWindow extends FarmWindow
   {
      
      private static const SERVICE_NAME:String = "IsraelInnovationService";
      
      private static const VAL_GLOBAL_LEADERBOARD:String = "globalLeaderboardData";
      
      private static const VAL_PREVIOUS_LEADERBOARD:String = "previousLeaderboardData";
      
      private var m_featureName:String = null;
      
      private var m_timer:Timer;
      
      private const TITLE_TF:String = "title_tf";
      
      private var m_timer_mc:MovieClip;
      
      private var m_rewards_mc:MovieClip;
      
      private var m_Reward_mc:MovieClip;
      
      private var m_leaderboard_mc:MovieClip;
      
      protected var m_highlightbgMc:MovieClip;
      
      private var m_loader_mc:MovieClip;
      
      private var timeleft_frame:ZwFrame;
      
      private var FEATURE_NAME:String = "IsraelInnovation";
      
      public var m_communityScore:Array = [0,0];
      
      private var m_task:IsraelInnovationCommunityGoalTask;
      
      private var m_taskList:Array;
      
      private const COMMUNITY_WELCOME_SEEN_FLAG:String = "Community_Goal_Welcome_flag";
      
      private var npcCallTitle:Array = ["The Busy Bee","The Generous Heart"];
      
      private var npcCallSubtitle:Array = ["The community recognizes <Player name> for the most number of orders completed this week! Congrats <Player name>","Player name> has sharing the most number of Bundles of Plenty this week! Thanks for sharing and caring <Player name>"];
      
      private var m_idleNPC:MovieClip;
      
      private var m_iconhitWidget1:ZwFrame;
      
      private var m_iconhitWidget2:ZwFrame;
      
      private var m_talkMc:MovieClip;
      
      private var m_npc1Tf:ZwTextField;
      
      private var m_npc2Tf:ZwTextField;
      
      private var m_name1_tf:ZwTextField;
      
      private var m_name2_tf:ZwTextField;
      
      private var m_icon1_mc:FarmIcon;
      
      private var m_icon2_mc:FarmIcon;
      
      private var m_talkAutoMc:MovieClip;
      
      private var m_autoTalkMc:MovieClip;
      
      private var m_autoNpc1Tf:ZwTextField;
      
      private var m_autoNpc2Tf:ZwTextField;
      
      private var m_timer_tf:ZwTextField;
      
      private var m_owner:IsraelInnovationMainWindow;
      
      public var m_CommunityFrame:IsraelInnovationCommunityGoalFrame;
      
      private var m_showReward:Boolean;
      
      public function IsraelInnovationCommunityGoalWindow(assetPath:String = "", featureName:String = null, ownerWindow:IsraelInnovationMainWindow = null, taskList:Array = null, showReward:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_owner = ownerWindow;
         this.m_taskList = taskList;
         this.m_showReward = showReward;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var timeLeftInWeek:Number = NaN;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"FARM-OFF COMMUNITY"));
         }
         if(m_window.hasOwnProperty("subtitle_tf"))
         {
            addWidget(new ZwTextField(m_window["subtitle_tf"],"Share the work and everybody reaps great rewards!"));
         }
         if(m_window.hasOwnProperty("timer_mc"))
         {
            this.m_timer_mc = m_window["timer_mc"] as MovieClip;
            this.m_timer_mc.visible = true;
            if(this.m_timer_mc.hasOwnProperty("timer_tf"))
            {
               addWidget(this.m_timer_tf = new ZwTextField(this.m_timer_mc["timer_tf"]));
               timeLeftInWeek = this.manager.getTimeLeftInWeek();
               if(timeLeftInWeek == -1)
               {
                  this.m_timer_mc.visible = false;
               }
               else
               {
                  this.m_timer_tf.text = HUD.getformattedTimeLeft(timeLeftInWeek) + " Left";
               }
            }
         }
         if(m_window.hasOwnProperty("idle_ani_mc"))
         {
            this.m_idleNPC = m_window["idle_ani_mc"] as MovieClip;
            this.playIdleNPCAnimation();
         }
         if(m_window.hasOwnProperty("talk_mc"))
         {
            this.m_talkMc = m_window.talk_mc as MovieClip;
            this.m_talkMc.visible = false;
            addWidget(this.m_npc1Tf = new ZwTextField(this.m_talkMc["npc1_tf"],"npc1"));
            addWidget(this.m_npc2Tf = new ZwTextField(this.m_talkMc["npc2_tf"],"Default NPC Text"));
         }
         if(m_window.hasOwnProperty("talk_auto_mc"))
         {
            this.m_talkAutoMc = m_window.talk_auto_mc as MovieClip;
            this.m_talkAutoMc.visible = false;
            if(this.m_talkAutoMc.hasOwnProperty("talk_mc"))
            {
               this.m_autoTalkMc = this.m_talkAutoMc.talk_mc as MovieClip;
               this.m_autoTalkMc.visible = true;
               this.m_autoNpc1Tf = new ZwTextField(this.m_autoTalkMc["npc1_tf"]," Auto npc1");
               this.m_autoNpc2Tf = new ZwTextField(this.m_autoTalkMc["npc2_tf"],"Auto Default NPC Text");
            }
         }
         if(m_window.hasOwnProperty("title1_tf"))
         {
            addWidget(new ZwTextField(m_window["title1_tf"],"Busy Bee"));
         }
         if(m_window.hasOwnProperty("title2_tf"))
         {
            addWidget(new ZwTextField(m_window["title2_tf"],"Generous Heart"));
         }
         if(m_window.hasOwnProperty("name1_tf"))
         {
            addWidget(this.m_name1_tf = new ZwTextField(m_window["name1_tf"],""));
         }
         if(m_window.hasOwnProperty("name2_tf"))
         {
            addWidget(this.m_name2_tf = new ZwTextField(m_window["name2_tf"],""));
         }
         if(m_window.hasOwnProperty("icon1_mc"))
         {
            addWidget(this.m_icon1_mc = new FarmIcon(m_window["icon1_mc"]));
            this.m_icon1_mc.visible = true;
            this.m_iconhitWidget1 = new ZwFrame(m_window["icon1_mc"] as MovieClip);
            if(this.m_name1_tf.text != "")
            {
               this.m_iconhitWidget1.registerEventListener(MouseEvent.MOUSE_OVER,this.onProfileMouseOver(this.npcCallTitle[0],"The community recognizes " + this.m_name1_tf.text + " for the most number of orders completed this week! Congrats " + this.m_name1_tf.text + "!"));
               this.m_iconhitWidget1.registerEventListener(MouseEvent.MOUSE_OUT,this.onProfileMouseOut());
            }
         }
         if(m_window.hasOwnProperty("icon2_mc"))
         {
            addWidget(this.m_icon2_mc = new FarmIcon(m_window["icon2_mc"]));
            this.m_icon2_mc.visible = true;
            this.m_iconhitWidget2 = new ZwFrame(m_window["icon2_mc"] as MovieClip);
            if(this.m_name2_tf.text != "")
            {
               this.m_iconhitWidget2.registerEventListener(MouseEvent.MOUSE_OVER,this.onProfileMouseOver(this.npcCallTitle[1],this.m_name2_tf.text + " has sharing the most number of Bundles of Plenty this week! Thanks for sharing and caring " + this.m_name1_tf.text));
               this.m_iconhitWidget2.registerEventListener(MouseEvent.MOUSE_OUT,this.onProfileMouseOut());
            }
         }
         if(this.m_taskList.length == 1)
         {
            this.manager.getCommunityProgressForTask(this.m_taskList[0].name,this.updateFirstCommunityScore);
         }
         else if(this.m_taskList.length == 2)
         {
            this.manager.getCommunityProgressForTask(this.m_taskList[0].name,this.updateFirstCommunityScore);
            this.manager.getCommunityProgressForTask(this.m_taskList[1].name,this.updateSecondCommunityScore);
         }
         if(m_window.hasOwnProperty("goals_mc"))
         {
            this.m_CommunityFrame = new IsraelInnovationCommunityGoalFrame(m_window["goals_mc"],this,this.m_featureName,this.m_taskList);
            this.m_CommunityFrame.visible = true;
         }
         if(!this.hasSeenFeatureWelcome())
         {
            Global.player.setSeenFlag(this.COMMUNITY_WELCOME_SEEN_FLAG);
            this.showAutoHideNPCCallouts("A Friend in need...","Work with the community to finish challenges and everybody wins!");
         }
         this.manager.initializeCommGoalLeaderboard1();
         this.manager.initializeCommGoalLeaderboard2();
      }
      
      public function updateFirstCommunityScore(score:Number) : void
      {
         this.m_communityScore[0] = score;
         this.refreshCommGoalWindow();
      }
      
      public function updateSecondCommunityScore(score:Number) : void
      {
         this.m_communityScore[1] = score;
         this.refreshCommGoalWindow();
      }
      
      public function checkForCommunityGoalReward() : void
      {
         this.manager.initializeCommunityRewardGrant();
      }
      
      public function updateProfile1(data:Object) : void
      {
         var result:Object = null;
         if(data)
         {
            result = data[0];
            if(result)
            {
               if(result["name"] != null)
               {
                  this.m_name1_tf.text = result["name"];
                  this.m_name1_tf.visible = true;
                  this.m_iconhitWidget1.registerEventListener(MouseEvent.MOUSE_OVER,this.onProfileMouseOver(this.npcCallTitle[0],"The community recognizes " + this.m_name1_tf.text + " for the most number of orders completed this week! Congrats " + this.m_name1_tf.text + "!"));
                  this.m_iconhitWidget1.registerEventListener(MouseEvent.MOUSE_OUT,this.onProfileMouseOut());
               }
               else
               {
                  this.m_iconhitWidget1.registerEventListener(MouseEvent.MOUSE_OVER,this.onProfileMouseOver(this.npcCallTitle[0],"The community recognizes this Busy Bee for the most number of orders completed! Congrats Farmer!"));
                  this.m_iconhitWidget1.registerEventListener(MouseEvent.MOUSE_OUT,this.onProfileMouseOut());
               }
               if(result["icon"])
               {
                  this.m_icon1_mc.loadIcon(result["icon"]);
                  this.m_icon1_mc.setIconSize(70,70);
                  this.m_icon1_mc.setSmoothing(true);
               }
            }
            else
            {
               this.m_iconhitWidget1.registerEventListener(MouseEvent.MOUSE_OVER,this.onProfileMouseOver(this.npcCallTitle[0],"The community recognizes this Busy Bee for the most number of orders completed! Congrats Farmer!"));
               this.m_iconhitWidget1.registerEventListener(MouseEvent.MOUSE_OUT,this.onProfileMouseOut());
            }
         }
         else
         {
            this.m_iconhitWidget1.registerEventListener(MouseEvent.MOUSE_OVER,this.onProfileMouseOver(this.npcCallTitle[0],"The community recognizes this Busy Bee for the most number of orders completed! Congrats Farmer!"));
            this.m_iconhitWidget1.registerEventListener(MouseEvent.MOUSE_OUT,this.onProfileMouseOut());
         }
      }
      
      public function updateProfile2(data:Object) : void
      {
         var result:Object = null;
         if(data)
         {
            result = data[0];
            if(result)
            {
               if(result["name"] != null)
               {
                  this.m_name2_tf.text = result["name"];
                  this.m_name2_tf.visible = true;
                  this.m_iconhitWidget2.registerEventListener(MouseEvent.MOUSE_OVER,this.onProfileMouseOver(this.npcCallTitle[1],this.m_name2_tf.text + " has sharing the most number of Bundles of Plenty this week! Thanks for sharing and caring " + this.m_name2_tf.text));
                  this.m_iconhitWidget2.registerEventListener(MouseEvent.MOUSE_OUT,this.onProfileMouseOut());
               }
               else
               {
                  this.m_iconhitWidget2.registerEventListener(MouseEvent.MOUSE_OVER,this.onProfileMouseOver(this.npcCallTitle[1],"The community thanks this Generous Heart for most shared Bundles of Plenty! Thank you Farmer!"));
                  this.m_iconhitWidget2.registerEventListener(MouseEvent.MOUSE_OUT,this.onProfileMouseOut());
               }
               if(result["icon"])
               {
                  this.m_icon2_mc.loadIcon(result["icon"]);
                  this.m_icon2_mc.setIconSize(70,70);
                  this.m_icon2_mc.setSmoothing(true);
               }
            }
            else
            {
               this.m_iconhitWidget2.registerEventListener(MouseEvent.MOUSE_OVER,this.onProfileMouseOver(this.npcCallTitle[1],"The community thanks this Generous Heart for most shared Bundles of Plenty! Thank you Farmer!"));
               this.m_iconhitWidget2.registerEventListener(MouseEvent.MOUSE_OUT,this.onProfileMouseOut());
            }
         }
         else
         {
            this.m_iconhitWidget2.registerEventListener(MouseEvent.MOUSE_OVER,this.onProfileMouseOver(this.npcCallTitle[1],"The community thanks this Generous Heart for most shared Bundles of Plenty! Thank you Farmer!"));
            this.m_iconhitWidget2.registerEventListener(MouseEvent.MOUSE_OUT,this.onProfileMouseOut());
         }
      }
      
      private function get manager() : IsraelInnovationManager
      {
         return IsraelInnovationManager.getInstance();
      }
      
      public function playIdleNPCAnimation() : void
      {
         var child:MovieClip = null;
         var grandChildIndex:int = 0;
         var grandChild:MovieClip = null;
         this.m_idleNPC.visible = true;
         for(var childIndex:int = 1; childIndex < this.m_idleNPC.numChildren; childIndex++)
         {
            child = this.m_idleNPC.getChildAt(childIndex) as MovieClip;
            if(child)
            {
               child.play();
               for(grandChildIndex = 1; grandChildIndex < child.numChildren; grandChildIndex++)
               {
                  grandChild = child.getChildAt(grandChildIndex) as MovieClip;
                  if(grandChild)
                  {
                     grandChild.play();
                  }
               }
            }
         }
         this.m_idleNPC.play();
      }
      
      private function hasSeenFeatureWelcome() : Boolean
      {
         return Global.player.getSeenFlag(this.COMMUNITY_WELCOME_SEEN_FLAG);
      }
      
      private function showAutoHideNPCCallouts(title:String, text:String) : void
      {
         this.m_autoNpc2Tf.text = text;
         this.m_autoNpc1Tf.text = title;
         this.m_talkAutoMc.visible = true;
         this.m_talkAutoMc.gotoAndPlay(1);
      }
      
      public function showNPCCallouts(title:String, text:String) : void
      {
         this.m_npc1Tf.text = title;
         this.m_npc2Tf.text = text;
         this.m_talkMc.visible = true;
      }
      
      public function hideNPCCallout() : void
      {
         this.m_talkMc.visible = false;
      }
      
      override public function close() : void
      {
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
         }
         super.close();
      }
      
      public function onProfileMouseOver(title:String = "", text:String = "") : Function
      {
         return function(evt:MouseEvent):void
         {
            m_npc1Tf.text = title;
            m_npc2Tf.text = text;
            m_talkMc.visible = true;
         };
      }
      
      public function onProfileMouseOut() : Function
      {
         return function(evt:MouseEvent):void
         {
            m_talkMc.visible = false;
         };
      }
      
      public function refreshCommGoalWindow() : void
      {
         if(this.m_CommunityFrame)
         {
            this.m_CommunityFrame.refresh();
         }
      }
      
      public function isEligibleForRewards(index:int = 0) : Boolean
      {
         var result:Boolean = false;
         var playerCount:Number = this.manager.getCommGoalPlayerCountForTask(this.m_taskList[index].name);
         if(playerCount >= this.m_taskList[index].playerGoal)
         {
            result = true;
         }
         return result;
      }
   }
}

