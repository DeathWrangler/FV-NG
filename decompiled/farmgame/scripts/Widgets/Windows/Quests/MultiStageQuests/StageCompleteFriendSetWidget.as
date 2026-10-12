package Widgets.Windows.Quests.MultiStageQuests
{
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.Friend;
   import Classes.FriendSetGoal;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmTask;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.MFSRequestManager;
   import Managers.TemplateUIUtility;
   import Transactions.Quests.TSkipCompleteFriendSetTask;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import ZQuest.Events.QuestEvent;
   import ZQuest.Managers.QuestManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class StageCompleteFriendSetWidget extends AbstractStageWidget
   {
      
      private var m_askButton:FarmAnimatedTextButton;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      private var m_friendSetGoal:FriendSetGoal;
      
      private var m_numFriends:int;
      
      private const HAS_COMPLETE_NOW_FLAG_PREFIX:String = "Tried_Complete_Now_";
      
      private var m_completeCallback:Function;
      
      public function StageCompleteFriendSetWidget(element:DisplayObject, quest:FarmQuest, parentWindow:FarmWindow = null, stage:int = 1, completeCallback:Function = null)
      {
         super(element,quest,parentWindow,stage);
         var x:String = ZLocUtils.t("Dialogs","MultiStageQuestGeneric_AskFriendSet");
         var completeNowText:String = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",quest.name + "_BuyFriendSet"),new ZLocFailoverEntry("Dialogs","MultiStageQuestGeneric_BuyFriendSet")]);
         this.m_completeCallback = completeCallback;
         this.m_askButton = addWidget(new FarmAnimatedTextButton(m_element.ask_bt,ZLocUtils.t("Dialogs","MultiStageQuestGeneric_AskFriendSet"),this.onAskForHelp)) as FarmAnimatedTextButton;
         this.m_askButton.enabled = false;
         this.m_buyButton = addWidget(new FarmAnimatedCashButton(m_element.buy_bt,completeNowText,"00",this.onBuyFriendSet,false,false,true)) as FarmAnimatedCashButton;
         this.m_buyButton.enabled = false;
         if(m_element.hasOwnProperty("prizeIcon_mc"))
         {
            addWidget(new ZwBaseWidget(m_element.prizeIcon_mc));
            (m_element.prizeIcon_mc as MovieClip).play();
         }
         this.m_numFriends = m_farmQuest.farmTasks[0].total;
         this.initializeBlankFriendSetUI();
         this.loadFriendSet();
      }
      
      private function loadFriendSet() : void
      {
         var friendSetCode:String = m_farmQuest.farmTasks[0].type;
         var friendSetXml:XML = Global.farmGameSettingsManager.getFriendSetXMLByCode(friendSetCode);
         this.m_friendSetGoal = Global.farmGameSettingsManager.getFriendSetGoalByCode(friendSetCode);
         this.m_friendSetGoal.friendSet = FriendSet.factory(friendSetCode);
         this.m_friendSetGoal.friendSet.addEventListener(Event.COMPLETE,this.onFriendSetInitialized);
         this.m_friendSetGoal.friendSet.initializeData();
      }
      
      private function onFriendSetInitialized(event:Event) : void
      {
         this.m_friendSetGoal.friendSet.removeEventListener(Event.COMPLETE,this.onFriendSetInitialized);
         this.populateFriendSet();
         QuestManager.getInstance().addEventListener(QuestEvent.PROGRESS,this.onQuestUpdate);
      }
      
      private function onQuestUpdate(event:QuestEvent) : void
      {
         this.m_buyButton.setAmountText(String(this.getCompletionCost()));
         QuestManager.getInstance().removeEventListener(QuestEvent.PROGRESS,this.onQuestUpdate);
      }
      
      private function populateFriendSet() : void
      {
         var slot:ZwFrame = null;
         var friendData:Friend = null;
         var icon:FarmIcon = null;
         var friends:Array = this.m_friendSetGoal.friendSet.completedFriends;
         var i:int = 0;
         i = 0;
         while(i < this.m_numFriends && i < friends.length)
         {
            slot = getWidget("slot_" + i + "_mc") as ZwFrame;
            friendData = Global.friendManager.getFriendData(friends[i]);
            if(friendData)
            {
               (slot.getWidget("name_tf") as ZwTextField).text = friendData.firstName;
               icon = slot.getWidget("loader_mc") as FarmIcon;
               icon.visible = true;
               icon.loadIcon(friendData.picture);
            }
            i++;
         }
         this.m_buyButton.element.cost_tf.text = String(this.getCompletionCost());
         this.m_askButton.enabled = !this.waitingForCompleteNow();
         this.m_buyButton.enabled = !this.waitingForCompleteNow();
      }
      
      private function getCompletionCost() : int
      {
         var task:FarmTask = m_farmQuest.farmTasks[0];
         return task.cashValue;
      }
      
      private function initializeBlankFriendSetUI() : void
      {
         var slotFrame:ZwFrame = null;
         var textColor:String = null;
         var correctNumFriendsElementName:String = null;
         var slotIndex:int = 0;
         var correctFriendSlotElementName:String = null;
         var nameTextField:ZwTextField = null;
         var colorWidget:ZwBaseWidget = null;
         var i:int = 0;
         var emptySlotText:String = this.getEmptyFriendSlotText();
         if(Boolean(m_parentWindow) && Boolean(m_parentWindow as MultiStageQuestDialog) && (m_parentWindow as MultiStageQuestDialog).isTemplateUIEnabled())
         {
            textColor = (m_parentWindow as MultiStageQuestDialog).textColor;
            if(Boolean(m_element) && Boolean(m_element["friends_mc"]))
            {
               addWidget(new ZwFrame(m_element.friends_mc));
               correctNumFriendsElementName = "items" + (this.m_numFriends - 1) + "_mc";
               if(m_element.friends_mc[correctNumFriendsElementName])
               {
                  addWidget(new ZwFrame(m_element.friends_mc[correctNumFriendsElementName]));
                  for(slotIndex = 0; slotIndex < this.m_numFriends; slotIndex++)
                  {
                     correctFriendSlotElementName = "slot_" + slotIndex + "_mc";
                     if(m_element.friends_mc[correctNumFriendsElementName][correctFriendSlotElementName])
                     {
                        slotFrame = addWidget(new ZwFrame(m_element.friends_mc[correctNumFriendsElementName][correctFriendSlotElementName])) as ZwFrame;
                        if(Boolean(slotFrame) && Boolean(slotFrame.element))
                        {
                           if(slotFrame.element["name_tf"])
                           {
                              nameTextField = slotFrame.addWidget(new ZwTextField(slotFrame.element.name_tf,emptySlotText)) as ZwTextField;
                              if(nameTextField)
                              {
                                 TemplateUIUtility.applyTextColor(nameTextField,TemplateUIUtility.ESCAPADE,textColor);
                              }
                           }
                           if(slotFrame.element["loader_mc"])
                           {
                              slotFrame.addWidget(new FarmIcon(slotFrame.element.loader_mc),false);
                           }
                           if(slotFrame.element["color_mc"])
                           {
                              colorWidget = slotFrame.addWidget(new ZwBaseWidget(slotFrame.element.color_mc)) as ZwBaseWidget;
                              if(Boolean(colorWidget) && Boolean(colorWidget.element) && Boolean(colorWidget.element as DisplayObject))
                              {
                                 TemplateUIUtility.applyBackgroundColor(colorWidget.element as DisplayObject,TemplateUIUtility.ESCAPADE,textColor);
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
         else
         {
            if(m_element.friends_mc)
            {
               addWidget(new ZwWidget(m_element.friends_mc));
            }
            for(i = 0; i < this.m_numFriends; i++)
            {
               if(Boolean(m_element) && Boolean(m_element.friends_mc) && Boolean(m_element.friends_mc["slot_" + i + "_mc"]))
               {
                  slotFrame = addWidget(new ZwFrame(m_element.friends_mc["slot_" + i + "_mc"])) as ZwFrame;
                  if(Boolean(slotFrame) && Boolean(slotFrame.element))
                  {
                     if(slotFrame.element.name_tf)
                     {
                        slotFrame.addWidget(new ZwTextField(slotFrame.element.name_tf,emptySlotText));
                     }
                     if(slotFrame.element.loader_mc)
                     {
                        slotFrame.addWidget(new FarmIcon(slotFrame.element.loader_mc),false);
                     }
                  }
               }
            }
         }
      }
      
      private function getEmptyFriendSlotText() : String
      {
         var failoverEntryArray:Array = new Array();
         if(m_farmQuest != null && m_farmQuest.hasOwnProperty("chain"))
         {
            failoverEntryArray.push(new ZLocFailoverEntry("Dialogs","MultiStageQuest_" + m_farmQuest.chain + "_FriendSetText"));
         }
         failoverEntryArray.push(new ZLocFailoverEntry("Dialogs","MultiStageQuestGeneric_FriendSetText"));
         return ZLocUtils.getFailoverLocString(failoverEntryArray);
      }
      
      private function onAskForHelp(event:Event) : void
      {
         var rewardName:String = null;
         var rewardCode:String = null;
         if(m_farmQuest.mfsItemName)
         {
            rewardName = m_farmQuest.mfsItemName;
         }
         else
         {
            rewardCode = m_farmQuest.farmRewards[0].value;
            rewardName = Global.farmGameSettingsManager.getFarmItemNameByCode(rewardCode);
         }
         MFSRequestManager.getInstance().makeFriendSetRequest(rewardName,this.m_friendSetGoal.name,this.m_friendSetGoal.code,-2);
         if(m_parentWindow)
         {
            m_parentWindow.close();
         }
      }
      
      private function waitingForCompleteNow() : Boolean
      {
         return Global.player.getSeenSessionFlag(this.HAS_COMPLETE_NOW_FLAG_PREFIX + m_farmQuest.name);
      }
      
      private function onBuyFriendSet(event:Event) : void
      {
         var cost:int = this.getCompletionCost();
         if(Global.player.canBuyCash(cost))
         {
            this.m_askButton.enabled = false;
            this.m_buyButton.enabled = false;
            Global.player.cash -= cost;
            Global.player.setSeenSessionFlag(this.HAS_COMPLETE_NOW_FLAG_PREFIX + m_farmQuest.name);
            TransactionManager.addTransaction(new TSkipCompleteFriendSetTask(m_farmQuest.name,0));
            if(m_parentWindow)
            {
               m_parentWindow.close();
            }
         }
      }
      
      override public function release() : void
      {
         super.release();
         QuestManager.getInstance().removeEventListener(QuestEvent.PROGRESS,this.onQuestUpdate);
         this.m_askButton = null;
         this.m_buyButton = null;
         this.m_completeCallback = null;
         this.m_friendSetGoal.friendSet.removeEventListener(Event.COMPLETE,this.onFriendSetInitialized);
         this.m_friendSetGoal = null;
      }
   }
}

