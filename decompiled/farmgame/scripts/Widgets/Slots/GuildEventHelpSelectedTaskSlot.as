package Widgets.Slots
{
   import Classes.Constants.QuestConstants;
   import Classes.Quest.FarmTask;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Events.FarmGameWorldEvent;
   import Events.GenericPopupEvent;
   import Managers.Crafting.CraftingManager;
   import Managers.GuildEventManager;
   import Managers.GuildManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.GuildEventMainWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class GuildEventHelpSelectedTaskSlot extends ZwSlotFrame
   {
      
      private static const coopXML:Class = GuildEventHelpSelectedTaskSlot_coopXML;
      
      public static const featureXML:XML = XML(new coopXML());
      
      private var m_featureName:String;
      
      private var m_owner:GuildEventMainWindow;
      
      private const ICON_MC:String = "icon_mc";
      
      private const TASK_BT:String = "task_bt";
      
      private const TASK1_BT:String = "task1_bt";
      
      private const DUMP_BT:String = "dump_bt";
      
      private const DUMPBG_MC:String = "dumpBG_mc";
      
      private const REDEEMBG_MC:String = "redeemBG_mc";
      
      private const TASKBG_MC:String = "taskBG_mc";
      
      private const SKIP_BT:String = "skip_bt";
      
      private const SKIP1_BT:String = "skip1_bt";
      
      private const TITLE_TF:String = "questtitle_tf";
      
      private const COUNT_TF:String = "questdone_tf";
      
      private const TRASH_TF:String = "trash_tf";
      
      private const POINTS_MC:String = "points_mc";
      
      private const POINTS_TF:String = "points_tf";
      
      private const ADDPOINTS_TF:String = "addpoints_tf";
      
      private const ANIMATION_MC:String = "animation_mc";
      
      private const CHECKMARK_MC:String = "checkmark_mc";
      
      private const HIT_AREA_MC:String = "hit_area_mc";
      
      private const HOVER_MC:String = "hover_mc";
      
      private const EXPANSION_TF:String = "expansion_tf";
      
      private var m_iconMc:FarmIcon;
      
      private var m_taskBt:FarmAnimatedTextButton;
      
      private var m_skipBt:FarmAnimatedCashButton;
      
      private var m_task1Bt:FarmAnimatedTextButton;
      
      private var m_skip1Bt:FarmAnimatedCashButton;
      
      private var m_dumpBt:FarmAnimatedTextButton;
      
      private var m_pointsMc:MovieClip;
      
      private var m_pointsTf:ZwTextField;
      
      private var m_countTf:ZwTextField;
      
      public var m_slotnumber:int;
      
      private var m_task:FarmTask;
      
      private var m_data:Object;
      
      private var m_titelTf:ZwTextField;
      
      private var m_isCallbackNull:Boolean = false;
      
      private var modifiedIconUrl:String;
      
      private var progress:int;
      
      private var total:int;
      
      private var m_trashTf:ZwTextField;
      
      private var m_addpointsTf:ZwTextField;
      
      private var m_animationMc:MovieClip;
      
      private var m_dumpBG:ZwFrame;
      
      private var m_redeemBG:ZwFrame;
      
      private var m_taskBG:ZwFrame;
      
      private var m_checkmark:MovieClip;
      
      private var m_hover_mc:MovieClip;
      
      private var m_hit_area_mc:MovieClip;
      
      private var m_help_bt:FarmAnimatedTextButton;
      
      private var m_toolTip:FarmTextTooltip;
      
      private var m_expansionTf:ZwTextField;
      
      public function GuildEventHelpSelectedTaskSlot(featureName:String, element:DisplayObject, window:GuildEventMainWindow)
      {
         this.m_featureName = featureName;
         this.m_owner = window;
         super(element);
         if(m_element.hasOwnProperty(this.ICON_MC))
         {
            addWidget(this.m_iconMc = new FarmIcon(m_element[this.ICON_MC]));
         }
         if(m_element.hasOwnProperty(this.TASK_BT))
         {
            addWidget(this.m_taskBt = new FarmAnimatedTextButton(m_element[this.TASK_BT],"Task",this.onClickTaskButton));
         }
         if(m_element.hasOwnProperty(this.TASK1_BT))
         {
            addWidget(this.m_task1Bt = new FarmAnimatedTextButton(m_element[this.TASK1_BT],"Select!",this.onClickTask1ButtonGetNewTask));
         }
         if(m_element.hasOwnProperty(this.SKIP_BT))
         {
            addWidget(this.m_skipBt = new FarmAnimatedCashButton(m_element[this.SKIP_BT],"Complete","3",this.onClickSkipButton));
         }
         if(m_element.hasOwnProperty(this.SKIP1_BT))
         {
            addWidget(this.m_skip1Bt = new FarmAnimatedCashButton(m_element[this.SKIP1_BT],"Skip","1",this.onClickSkip1ButtonDumpedTask));
         }
         if(m_element.hasOwnProperty(this.DUMP_BT))
         {
            addWidget(this.m_dumpBt = new FarmAnimatedTextButton(m_element[this.DUMP_BT],"Trash",this.onClickDumpButton));
         }
         if(m_element.hasOwnProperty(this.EXPANSION_TF))
         {
            this.m_expansionTf = new ZwTextField(m_element[this.EXPANSION_TF]);
         }
         if(m_element.hasOwnProperty(this.POINTS_MC))
         {
            this.m_pointsMc = m_element[this.POINTS_MC] as MovieClip;
            if(m_element[this.POINTS_MC].hasOwnProperty(this.POINTS_TF))
            {
               this.m_pointsTf = new ZwTextField(m_element[this.POINTS_MC][this.POINTS_TF]);
            }
         }
         if(m_element.hasOwnProperty(this.TITLE_TF))
         {
            this.m_titelTf = new ZwTextField(m_element[this.TITLE_TF]);
         }
         if(m_element.hasOwnProperty(this.COUNT_TF))
         {
            this.m_countTf = new ZwTextField(m_element[this.COUNT_TF]);
         }
         if(m_element.hasOwnProperty(this.TRASH_TF))
         {
            this.m_trashTf = new ZwTextField(m_element[this.TRASH_TF]);
         }
         if(m_element.hasOwnProperty(this.ADDPOINTS_TF))
         {
            this.m_addpointsTf = new ZwTextField(m_element[this.ADDPOINTS_TF]);
         }
         if(m_element.hasOwnProperty(this.ANIMATION_MC))
         {
            this.m_animationMc = m_element[this.ANIMATION_MC] as MovieClip;
         }
         if(m_element.hasOwnProperty(this.DUMPBG_MC))
         {
            this.m_dumpBG = new ZwFrame(m_element[this.DUMPBG_MC]);
         }
         if(m_element.hasOwnProperty(this.REDEEMBG_MC))
         {
            this.m_redeemBG = new ZwFrame(m_element[this.REDEEMBG_MC]);
         }
         if(m_element.hasOwnProperty(this.TASKBG_MC))
         {
            this.m_taskBG = new ZwFrame(m_element[this.TASKBG_MC]);
         }
         if(m_element.hasOwnProperty(this.CHECKMARK_MC))
         {
            this.m_checkmark = m_element[this.CHECKMARK_MC] as MovieClip;
         }
         if(m_element.hasOwnProperty(this.HOVER_MC))
         {
            this.m_hover_mc = m_element[this.HOVER_MC] as MovieClip;
            this.m_hover_mc.visible = true;
            if(this.m_hover_mc.hasOwnProperty("help_bt"))
            {
               addWidget(this.m_help_bt = new FarmAnimatedTextButton(this.m_hover_mc["help_bt"],"Need Help",this.onHelpButtonClick));
               this.m_help_bt.visible = true;
            }
         }
         if(m_element.hasOwnProperty(this.HIT_AREA_MC))
         {
            this.m_hit_area_mc = m_element[this.HIT_AREA_MC] as MovieClip;
            this.m_hit_area_mc.visible = true;
            (this.m_hit_area_mc as MovieClip).addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
            (this.m_hit_area_mc as MovieClip).addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
         }
      }
      
      private static function toggleButton(button:FarmAnimatedTextButton, to:Boolean) : void
      {
         button.enabled = to;
         button.applyGrayOut = !to;
      }
      
      override public function populate(data:Object) : void
      {
         var expansionText:String = null;
         var tooltipText:String = null;
         var bushelQty:int = 0;
         var lockedState:int = 0;
         var playerId:String = null;
         var profilePicPath:String = null;
         var profileNameh:String = null;
         var icon:FarmIcon = null;
         super.populate(data);
         this.resetAllButtonsAndTextFeilds();
         if(Boolean(data) && data.hasOwnProperty("questTaskSlotNumber"))
         {
            this.m_slotnumber = data.questTaskSlotNumber;
         }
         if(data.questType == "DummyTask")
         {
            this.m_dumpBG.visible = true;
            this.m_dumpBt.visible = false;
            this.m_countTf.visible = false;
            this.m_iconMc.visible = false;
            this.m_taskBt.visible = false;
            this.m_skipBt.visible = false;
            this.m_titelTf.visible = false;
            this.m_trashTf.visible = true;
            this.m_trashTf.text = "Add Task";
            this.m_task1Bt.enabled = true;
            this.m_task1Bt.visible = true;
            this.m_skip1Bt.visible = false;
            this.m_expansionTf.visible = false;
         }
         else
         {
            this.m_data = data;
            this.m_trashTf.visible = false;
            this.m_task1Bt.visible = false;
            this.m_skip1Bt.visible = false;
            this.m_checkmark.visible = false;
            this.m_animationMc.visible = false;
            this.m_addpointsTf.visible = false;
            if(Boolean(data) && data.hasOwnProperty("questTask"))
            {
               this.m_task = data.questTask;
            }
            if(this.m_task.iconUrl)
            {
               this.modifiedIconUrl = this.getIconUrl();
               this.m_iconMc.visible = true;
               this.m_iconMc.loadIcon(this.modifiedIconUrl);
               this.m_iconMc.setIconSize(70,70);
               this.m_iconMc.setSmoothing(true);
            }
            if(Boolean(data) && data.hasOwnProperty("questText"))
            {
               this.m_titelTf.text = this.getQuestTitleText(data.questText);
               this.m_titelTf.visible = true;
            }
            if(Boolean(data) && Boolean(data.hasOwnProperty("taskType")) && data.hasOwnProperty("helperText"))
            {
               this.setHelperText(data.helperText);
               this.setSkipButton((data.skipCashValue / 2).toString());
            }
            if(Boolean(this.m_data) && this.m_data.hasOwnProperty("progress"))
            {
               this.progress = int(this.m_data.progress);
               this.total = int(this.m_task.total / 2);
               this.m_countTf.text = this.progress.toString() + "/" + this.total.toString();
               this.m_countTf.visible = true;
            }
            if(this.m_expansionTf)
            {
               expansionText = "";
               if(this.eventManager.shouldTravelTask(this.m_task.action))
               {
                  expansionText = this.eventManager.getExpansionName(this.m_task.action,this.m_task.type);
               }
               this.m_expansionTf.text = expansionText;
               this.m_expansionTf.visible = true;
            }
            if(this.eventManager.isTaskDumped(this.m_slotnumber))
            {
               this.m_dumpBG.visible = true;
               this.m_dumpBt.visible = false;
               this.m_redeemBG.visible = false;
               this.m_taskBG.visible = false;
               this.m_countTf.visible = false;
               this.m_iconMc.visible = false;
               this.m_taskBt.visible = false;
               this.m_skipBt.visible = false;
               this.m_titelTf.visible = false;
               this.m_trashTf.visible = true;
               this.m_isCallbackNull = false;
               this.m_expansionTf.visible = false;
               if(this.eventManager.canDumpTask(this.m_slotnumber))
               {
                  this.m_trashTf.text = "";
                  this.m_task1Bt.enabled = true;
                  this.m_task1Bt.visible = true;
                  this.m_skip1Bt.visible = false;
               }
               else
               {
                  this.m_trashTf.text = "Next task appears in " + FarmGameUtil.toFriendlyTime(this.eventManager.getTimeRemainingForDumpedTask(this.m_slotnumber));
                  this.m_dumpBt.enabled = false;
                  this.m_task1Bt.visible = false;
                  this.m_skip1Bt.enabled = true;
                  this.m_skip1Bt.visible = true;
               }
            }
            else
            {
               this.m_dumpBG.visible = false;
               this.m_redeemBG.visible = false;
               this.m_taskBG.visible = true;
               this.m_taskBt.callback = this.onClickTaskButton;
               this.m_isCallbackNull = false;
               this.m_dumpBt.visible = true;
               if(this.eventManager.canDumpTask(this.m_slotnumber))
               {
                  this.m_dumpBt.enabled = true;
               }
               else
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_dumpBt,"You can again trash task in " + FarmGameUtil.toFriendlyTime(this.eventManager.getTimeRemainingForDumpedTask(this.m_slotnumber)));
                  this.m_dumpBt.callback = null;
               }
               this.m_pointsMc.visible = true;
               this.m_pointsTf.visible = true;
               this.m_pointsTf.text = (this.m_task.questPoints / 2).toString();
            }
            if(this.m_task.action == QuestConstants.TASK_USE_ITEM_BY_CODE)
            {
               this.m_taskBt.enabled = this.m_task.canAskForHelp();
            }
            if(Boolean(data) && Boolean(data.hasOwnProperty("completed")) && Boolean(data.completed))
            {
               this.m_checkmark.visible = true;
               this.m_dumpBt.visible = false;
               this.m_skipBt.visible = false;
               this.m_taskBt.visible = true;
               this.m_taskBt.enabled = true;
               this.m_taskBt.text = "Redeem";
               this.m_redeemBG.visible = true;
               this.m_taskBG.visible = false;
               this.m_dumpBG.visible = true;
            }
            if(!this.m_taskBt.enabled)
            {
               tooltipText = data.helperText;
               this.m_taskBt.callback = null;
               this.m_isCallbackNull = true;
               FarmGameUtil.disableButtonAndShowTooltip(this.m_taskBt,tooltipText);
            }
            else
            {
               toggleButton(this.m_taskBt,true);
            }
            if(this.m_task.helperType == QuestConstants.HELPER_TYPE_SINK_GOLD)
            {
               this.m_countTf.text = (this.m_task.total / 2).toString();
               if(!Global.player.canBuy(this.m_task.total / 2,false))
               {
                  this.m_taskBt.enabled = false;
                  this.m_taskBt.callback = null;
                  this.m_isCallbackNull = true;
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_taskBt,"You don\'t have enough coins!");
               }
            }
            else if(this.m_task.helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
            {
               bushelQty = CraftingManager.getInstance().getBushelQuantityInInventory(this.m_task.type);
               if(bushelQty < this.m_task.total / 2)
               {
               }
            }
            else if(this.m_task.helperType == QuestConstants.HELPER_TYPE_OPEN_CRAFTING)
            {
               if(this.compareWorlds() == null)
               {
                  lockedState = CraftingManager.getInstance().isRecipeLocked(this.m_task.type);
                  if(lockedState > 0)
                  {
                     this.m_taskBt.callback = null;
                     this.m_isCallbackNull = true;
                     FarmGameUtil.disableButtonAndShowTooltip(this.m_taskBt,CraftingManager.getInstance().getRecipeLockedReason(this.m_task.type,lockedState));
                  }
               }
            }
            if(!this.m_isCallbackNull)
            {
               this.m_taskBt.detachTooltip();
            }
         }
         if(Boolean(data) && Boolean(data.hasOwnProperty("extraData")) && Boolean(data["extraData"].hasOwnProperty("playerId")))
         {
            playerId = data["extraData"]["playerId"];
            profilePicPath = GuildManager.getInstance().getGuildMemberPic(playerId);
            profileNameh = GuildManager.getInstance().getGuildMemberName(playerId);
            icon = new FarmIcon(m_element["profile_mc"] as MovieClip,profilePicPath);
            icon.setIconSize(50,50);
            icon.detachTooltip();
            icon.visible = true;
            if(this.m_toolTip)
            {
               this.m_toolTip.setText(profileNameh);
            }
            else
            {
               icon.attachTooltip(this.m_toolTip = new FarmTextTooltip(profileNameh));
            }
         }
      }
      
      private function setSkipButton(cost:String) : void
      {
         this.m_skipBt.enabled = true;
         this.m_skipBt.visible = true;
         this.m_skipBt.setAmountText(cost);
      }
      
      public function listenForAnimationEnd(e:Event = null) : void
      {
         if(this.m_animationMc.currentFrame == 40)
         {
            this.m_animationMc.gotoAndStop(1);
            this.m_animationMc.visible = false;
            this.m_animationMc.removeEventListener(Event.ENTER_FRAME,this.listenForAnimationEnd,false);
         }
      }
      
      private function onClickTaskButton(event:Event) : void
      {
         var confirmationText:String = null;
         this.m_taskBt.enabled = false;
         var world:String = null;
         if(Boolean(this.m_data) && Boolean(this.m_data.hasOwnProperty("completed")) && Boolean(this.m_data.completed))
         {
            if(this.m_task.helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
            {
               this.eventManager.sinkBushel(this.m_slotnumber);
            }
            else if(this.m_task.helperType == QuestConstants.HELPER_TYPE_WORLD_SCORE)
            {
               this.eventManager.redeemWorldScoreTask(this.m_slotnumber);
            }
            else
            {
               this.eventManager.redeemSlotTask(this.m_slotnumber);
            }
            this.m_animationMc.visible = true;
            this.m_animationMc.gotoAndPlay(1);
            this.m_animationMc.addEventListener(Event.ENTER_FRAME,this.listenForAnimationEnd,false,0,true);
         }
         else if(this.m_task.helperType == QuestConstants.HELPER_TYPE_SINK_GOLD)
         {
            confirmationText = ZLocUtils.t("Dialogs","SinkGoldTaskConfirmation",{"quantity":this.m_task.total / 2});
            if(UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptSinkGoldConfirmation,"farmAnimatedTextConfirmation",true,true))
            {
               this.m_taskBt.enabled = false;
               this.m_owner.tintWindow();
               this.m_owner.enableInput = false;
            }
         }
         else if(this.m_task.type == featureXML.child("taskTypes").child("points").child("point1") && Global.worldManager.currentWorldType !== featureXML.child("worldNames").child("worldName1"))
         {
            this.onTravelButtonClick(featureXML.child("worldNames").child("worldName1"));
         }
         else if(this.m_task.type == featureXML.child("taskTypes").child("points").child("point2") && Global.worldManager.currentWorldType !== featureXML.child("worldNames").child("worldName2"))
         {
            this.onTravelButtonClick(featureXML.child("worldNames").child("worldName2"));
         }
         else if(this.eventManager.shouldTravelTask(this.m_task.action) == true && this.compareWorlds() != null)
         {
            world = this.compareWorlds();
            this.onTravelButtonClick(world);
         }
         else
         {
            StatsManager.count(this.m_featureName,this.getKingdomText(),this.getPhylumText(),(this.m_task.total / 2).toString());
            if(this.m_task)
            {
               this.m_task.performHelperAction(null,this.onAskFeedPosted);
            }
            if(this.m_task.action == QuestConstants.TASK_USE_ITEM_BY_CODE)
            {
               this.m_taskBt.enabled = false;
               this.m_taskBt.text = ZLocUtils.t("Quests","Helper_AskForHelp_InProgress");
            }
            else
            {
               this.m_owner.close();
               if(GuildManager.getInstance().m_guildMainWindow)
               {
                  GuildManager.getInstance().m_guildMainWindow.close();
               }
            }
         }
      }
      
      private function onAcceptSinkGoldConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.onClickSinkGoldButtonAfterConfirmation(event);
         }
         else
         {
            this.m_taskBt.enabled = true;
            this.m_owner.untintWindow();
            this.m_owner.enableInput = true;
         }
      }
      
      private function onClickSinkGoldButtonAfterConfirmation(event:Event) : void
      {
         this.m_animationMc.visible = true;
         this.m_animationMc.gotoAndPlay(1);
         this.m_animationMc.addEventListener(Event.ENTER_FRAME,this.listenForAnimationEnd,false,0,true);
         this.m_owner.untintWindow();
         this.m_owner.enableInput = true;
         this.eventManager.sinkGold(this.m_slotnumber);
      }
      
      private function onAskFeedPosted(success:Boolean) : void
      {
         var task:FarmTask = this.m_task;
         if(Boolean(this.m_taskBt) && Boolean(task) && success)
         {
            if(task.canAskForHelp())
            {
               this.m_taskBt.enabled = true;
               this.m_taskBt.text = ZLocUtils.t("Quests","Helper_AskForHelp_Button");
            }
            else
            {
               this.m_taskBt.enabled = false;
               this.m_taskBt.text = ZLocUtils.t("Quests","Helper_AskForHelp_Sent");
               this.m_taskBt.callback = null;
               if(this.m_owner)
               {
                  this.m_owner.refreshTaskFrame();
               }
               FarmGameUtil.disableButtonAndShowTooltip(this.m_taskBt,task.helperText);
            }
         }
      }
      
      private function onClickDumpButton(event:Event) : void
      {
         var confirmationText:String = ZLocUtils.t("Dialogs","TrashTaskConfirmation");
         if(this.m_owner)
         {
            this.m_owner.tintWindow();
            this.m_owner.enableInput = false;
         }
         if(UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptDumpConfirmation,"farmAnimatedTextConfirmation",true,true))
         {
            this.m_dumpBt.enabled = false;
            this.m_owner.tintWindow();
            this.m_owner.enableInput = false;
         }
      }
      
      private function onClickDumpButtonAfterConfirmation(event:Event) : void
      {
         this.m_owner.untintWindow();
         this.m_owner.enableInput = true;
         StatsManager.count(this.m_featureName,"Trash",this.getKingdomText(),this.getPhylumText(),"TaskSlot" + (this.m_slotnumber + 1).toString());
         this.eventManager.dumpTask(this.m_slotnumber);
      }
      
      private function onAcceptDumpConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.onClickDumpButtonAfterConfirmation(event);
         }
         else
         {
            this.m_dumpBt.enabled = true;
            this.m_owner.untintWindow();
            this.m_owner.enableInput = true;
         }
      }
      
      private function getIconUrl() : String
      {
         var result:String = "";
         return this.m_task.iconUrl;
      }
      
      private function getKingdomText() : String
      {
         var result:String = "";
         switch(this.m_task.helperType)
         {
            case QuestConstants.HELPER_TYPE_OPEN_FEATURE_CRAFTING:
            case QuestConstants.HELPER_TYPE_POP_STORAGE_BUILDING_DIALOG:
            case QuestConstants.HELPER_TYPE_CHAPTER_QUEST:
               result = "Open Reward";
               break;
            case QuestConstants.HELPER_TYPE_POST_ASK_FOR_ITEM_FEED_SPECIAL_QUEST:
               result = "Ask";
               break;
            case QuestConstants.HELPER_TYPE_PLANT_SEED:
               result = "Plant";
               break;
            case QuestConstants.HELPER_TYPE_OPEN_CRAFTING:
               result = "Craft";
               break;
            case QuestConstants.HELPER_TYPE_PAN_TO_ITEM:
               result = "Harvest BB";
               break;
            default:
               if(this.m_task.action == QuestConstants.TASK_HARVEST_BY_CATEGORY)
               {
                  if(this.m_task.type == "AllDreamworldR1Animal")
                  {
                     result = "Harvest Animals";
                  }
                  else if(this.m_task.type == "AllDreamworldR1Trees")
                  {
                     result = "Harvest Trees";
                  }
               }
         }
         return result;
      }
      
      private function getPhylumText() : String
      {
         var item:FarmItem = null;
         var result:String = "";
         switch(this.m_task.action)
         {
            case QuestConstants.TASK_COMPLETE_FEATURE_CRAFTING_NPC:
               result = "Elite Horse";
               break;
            case QuestConstants.TASK_EXPAND_STORAGE_BUILDING_TO_LEVEL_BY_CODE:
               result = "Harvest Buildable";
               break;
            case QuestConstants.TASK_HARVEST_BY_CODE:
            case QuestConstants.TASK_MAKE_RECIPE_BY_CODE:
            case QuestConstants.TASK_USE_ITEM_BY_CODE:
               if(this.m_task.helperType == QuestConstants.HELPER_TYPE_PAN_TO_ITEM)
               {
                  result = "Big Buildable";
               }
               else
               {
                  item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_task.type);
                  result = item.friendlyTitle;
               }
               break;
            case QuestConstants.TASK_HARVEST_BY_CATEGORY:
               result = this.m_task.type;
         }
         return result;
      }
      
      private function onClickTask1ButtonGetNewTask(event:Event) : void
      {
         this.m_taskBt.enabled = false;
         this.eventManager.openOrderboardSelectionUI(this.m_slotnumber);
      }
      
      private function onClickSkipButton(event:Event) : void
      {
         var confirmationText:String = ZLocUtils.t("Dialogs","TaskFarmCashBuyConfirmation",{"price":this.m_data.skipCashValue / 2});
         if(UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptSkipConfirmation,"farmAnimatedCashConfirmation",true,true))
         {
            this.m_skipBt.enabled = false;
            this.m_owner.tintWindow();
            this.m_owner.enableInput = false;
         }
      }
      
      private function onClickSkipButtonAfterConfirmation(event:Event) : void
      {
         this.eventManager.skipTask(this.m_slotnumber,this.m_owner.resumeWindow);
         if(Global.player.canBuyCash(this.m_task.skipCashValue / 2))
         {
            this.m_animationMc.visible = true;
            this.m_animationMc.gotoAndPlay(1);
            this.m_animationMc.addEventListener(Event.ENTER_FRAME,this.listenForAnimationEnd,false,0,true);
         }
      }
      
      private function onAcceptSkipConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.onClickSkipButtonAfterConfirmation(event);
         }
         else
         {
            this.m_skipBt.enabled = true;
            this.m_owner.untintWindow();
            this.m_owner.enableInput = true;
         }
      }
      
      private function onClickSkip1ButtonDumpedTask(event:Event) : void
      {
         var confirmationText:String = null;
         if(this.eventManager.isTaskDumped(this.m_slotnumber))
         {
            if(!this.eventManager.isTaskDumpTimeOver(this.m_slotnumber))
            {
               this.eventManager.skipDumpedTask(this.m_slotnumber);
            }
            else
            {
               confirmationText = "Wait time is already elapsed";
               UI.displayMessage(confirmationText,GenericPopup.TYPE_OK,this.eventManager.m_guildEventMainWindow.refreshTaskFrame,"",true);
            }
         }
      }
      
      private function get manager() : GuildManager
      {
         return GuildManager.getInstance(this.m_featureName);
      }
      
      private function get eventManager() : GuildEventManager
      {
         return GuildEventManager.getInstance(this.m_featureName);
      }
      
      private function setHelperText(requestText:String) : void
      {
         switch(this.m_task.helperType)
         {
            case QuestConstants.HELPER_TYPE_POST_ASK_FOR_ITEM_FEED:
            case QuestConstants.HELPER_TYPE_POST_ASK_FOR_ITEM_FEED_SPECIAL_QUEST:
               requestText = "Ask";
               break;
            case QuestConstants.HELPER_TYPE_PLANT_SEED:
               if(this.compareWorlds() !== null)
               {
                  requestText = "Travel";
               }
               else
               {
                  requestText = "Plant";
               }
               break;
            case QuestConstants.HELPER_TYPE_OPEN_CRAFTING:
               if(this.compareWorlds() !== null)
               {
                  requestText = "Travel";
               }
               else
               {
                  requestText = "Craft";
               }
               break;
            case QuestConstants.HELPER_TYPE_SINK_GOLD:
               requestText = ZLocUtils.t("Quests","Helper_Sink_Gold_Button");
               break;
            case QuestConstants.HELPER_TYPE_WORLD_SCORE:
               requestText = "";
               break;
            case QuestConstants.HELPER_TYPE_SINK_BUSHEL:
               if(this.compareWorlds() !== null)
               {
                  requestText = "Travel";
               }
               else if(Boolean(this.m_data) && Boolean(this.m_data.hasOwnProperty("completed")) && Boolean(this.m_data.completed))
               {
                  requestText = "Give";
               }
               else
               {
                  requestText = "Plant";
               }
               break;
            case QuestConstants.HELPER_TYPE_PAN_TO_ITEM:
               if(this.compareWorlds() !== null)
               {
                  requestText = "Travel";
               }
               else
               {
                  requestText = "Go To";
               }
         }
         if(requestText == "" || requestText == null)
         {
            this.m_taskBt.visible = false;
            return;
         }
         if(Boolean(this.m_taskBt.element) && this.m_taskBt.element.hasOwnProperty("generic_tf"))
         {
            this.m_taskBt.element.generic_tf.text = requestText;
            this.m_taskBt.enabled = true;
            this.m_taskBt.visible = true;
         }
      }
      
      private function resetAllButtonsAndTextFeilds() : void
      {
         this.m_dumpBt.enabled = false;
         this.m_dumpBt.visible = false;
         this.m_skipBt.enabled = false;
         this.m_skipBt.visible = false;
         this.m_taskBt.enabled = false;
         this.m_taskBt.visible = false;
         this.m_task1Bt.enabled = false;
         this.m_task1Bt.visible = false;
         this.m_iconMc.visible = false;
         this.m_titelTf.text = "";
         this.m_titelTf.visible = false;
         this.m_countTf.text = "";
         this.m_countTf.visible = false;
         this.m_pointsMc.visible = false;
         this.m_pointsTf.text = "";
         this.m_pointsTf.visible = false;
         this.m_addpointsTf.text = "";
         this.m_addpointsTf.visible = false;
         this.m_checkmark.visible = false;
         this.m_animationMc.visible = false;
         this.m_dumpBG.visible = false;
         this.m_expansionTf.text = "";
         this.m_expansionTf.visible = false;
      }
      
      public function onHelpButtonClick(e:Event) : void
      {
         GuildEventManager.getInstance().askForTaskHelp(this.m_slotnumber);
      }
      
      override public function release() : void
      {
         if(this.m_hover_mc)
         {
            (this.m_hover_mc as MovieClip).removeEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
            (this.m_hover_mc as MovieClip).removeEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
         }
         super.release();
      }
      
      private function onMouseOver(event:MouseEvent) : void
      {
      }
      
      private function onMouseOut(event:MouseEvent) : void
      {
      }
      
      public function compareWorlds() : String
      {
         var cropItem:FarmItem = null;
         var itemData:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_task.type);
         var worldName:String = itemData.worldRestrictions[0];
         var currentWorld:String = Global.worldManager.currentWorldType;
         if(this.m_task.helperType == QuestConstants.HELPER_TYPE_OPEN_CRAFTING)
         {
            worldName = Global.worldSettingsManager.getWorldNameByMarketCard(itemData.marketCardName);
         }
         else if(this.m_task.helperType == QuestConstants.HELPER_TYPE_SINK_BUSHEL)
         {
            cropItem = Global.farmGameSettingsManager.getFarmItemByCode(itemData.crop);
            worldName = cropItem.worldRestrictions[0];
         }
         if(worldName == currentWorld)
         {
            return null;
         }
         return worldName;
      }
      
      public function onTravelButtonClick(worldName:String) : void
      {
         if(Boolean(worldName) && worldName.length > 0)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
            this.m_owner.close();
            if(GuildManager.getInstance().m_guildMainWindow)
            {
               GuildManager.getInstance().m_guildMainWindow.close();
            }
         }
      }
      
      private function onWorldLoaded(event:FarmGameWorldEvent) : void
      {
         Global.worldManager.removeEventListener(FarmGameWorldEvent.WORLD_LOADED,this.onWorldLoaded);
         this.eventManager.m_guildEventMainWindow.close();
         this.eventManager.openGuildEventMainWindow();
      }
      
      public function shouldTravelTask(taskAction:String) : Boolean
      {
         var result:Boolean = false;
         if(taskAction == QuestConstants.TASK_SINK_BUSHEL || taskAction == QuestConstants.TASK_MAKE_RECIPE_BY_CODE || taskAction == QuestConstants.TASK_HARVEST_BY_CODE || taskAction == QuestConstants.TASK_HARVEST_BY_CATEGORY)
         {
            result = true;
         }
         return result;
      }
      
      private function getQuestTitleText(titleText:String) : String
      {
         var item:FarmItem = null;
         var result:String = "";
         switch(this.m_task.action)
         {
            case QuestConstants.TASK_HARVEST_BY_CATEGORY:
               if(this.m_task.type == featureXML.child("taskTypes").child("animals").child("animal1"))
               {
                  result = "Harvest " + (this.m_task.total / 2).toString() + " " + featureXML.child("animalsHarvestText").child("animalHarvest1Text");
               }
               else if(this.m_task.type == featureXML.child("taskTypes").child("trees").child("tree1"))
               {
                  result = "Harvest " + (this.m_task.total / 2).toString() + " " + featureXML.child("treesHarvestText").child("treeHarvest1Text");
               }
               else if(this.m_task.type == featureXML.child("taskTypes").child("animals").child("animal2"))
               {
                  result = "Harvest " + (this.m_task.total / 2).toString() + " " + featureXML.child("animalsHarvestText").child("animalHarvest2Text");
               }
               else if(this.m_task.type == featureXML.child("taskTypes").child("trees").child("tree2"))
               {
                  result = "Harvest " + (this.m_task.total / 2).toString() + " " + featureXML.child("treesHarvestText").child("treeHarvest2Text");
               }
               break;
            case QuestConstants.TASK_HARVEST_BY_CODE:
               if(this.m_task.type == featureXML.child("TASK_HARVEST_BY_CODE").child("TASK_HARVEST_BY_CODE_1").child("CODE"))
               {
                  result = "Harvest the " + featureXML.child("TASK_HARVEST_BY_CODE").child("TASK_HARVEST_BY_CODE_1").child("NAME") + " " + (this.m_task.total / 2).toString() + " times";
               }
               else if(this.m_task.type == featureXML.child("TASK_HARVEST_BY_CODE").child("TASK_HARVEST_BY_CODE_2").child("CODE"))
               {
                  result = "Harvest the " + featureXML.child("TASK_HARVEST_BY_CODE").child("TASK_HARVEST_BY_CODE_2").child("NAME") + " " + (this.m_task.total / 2).toString() + " times";
               }
               else
               {
                  item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_task.type);
                  if(item)
                  {
                     result = "Harvest " + (this.m_task.total / 2).toString() + " " + item.friendlyTitle;
                  }
               }
               break;
            case QuestConstants.TASK_USE_FAWN_FEED:
               result = "Use " + (this.m_task.total / 2).toString() + " Fawn Feed";
               break;
            case QuestConstants.TASK_WORLD_SCORE:
               if(this.m_task.type == featureXML.child("taskTypes").child("points").child("point1"))
               {
                  result = "Get " + (this.m_task.total / 2).toString() + " " + featureXML.child("taskTypes").child("points").child("point1Value");
               }
               else if(this.m_task.type == featureXML.child("taskTypes").child("points").child("point2"))
               {
                  result = "Get " + (this.m_task.total / 2).toString() + " " + featureXML.child("taskTypes").child("points").child("point2Value");
               }
               break;
            case QuestConstants.TASK_USE_SDB:
               result = "Use " + (this.m_task.total / 2).toString() + " Special Delivery Boxes";
               break;
            case QuestConstants.TASK_GROW_MYSTERY_SEEDLING:
               result = "Grow " + (this.m_task.total / 2).toString() + " mystery seedlings";
               break;
            case QuestConstants.TASK_USE_ITEM_BY_CODE:
               result = "Get " + (this.m_task.total / 2).toString() + " Hollers";
               break;
            case QuestConstants.TASK_MAKE_RECIPE_BY_CODE:
               item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_task.type);
               if(item)
               {
                  result = "Craft " + (this.m_task.total / 2).toString() + " " + item.friendlyTitle;
               }
               break;
            case QuestConstants.TASK_SINK_BUSHEL:
               item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_task.type);
               if(item)
               {
                  result = "Give " + (this.m_task.total / 2).toString() + " " + item.friendlyTitle;
               }
               break;
            default:
               result = titleText;
         }
         return result;
      }
   }
}

