package Widgets.Slots
{
   import Classes.Constants.QuestConstants;
   import Classes.Quest.FarmTask;
   import Classes.ZItem.FarmItem;
   import Managers.GuildEventManager;
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
   
   public class GuildEventHelpTasksSelectSlot extends ZwSlotFrame
   {
      
      private static const coopXML:Class = GuildEventHelpTasksSelectSlot_coopXML;
      
      public static const featureXML:XML = XML(new coopXML());
      
      private static const ICON_MC:String = "icon_mc";
      
      private static const TASK_BT:String = "task_bt";
      
      private static const POINTS_MC:String = "points_mc";
      
      private static const COUNT_TF:String = "questdone_tf";
      
      private static const HIT_AREA_MC:String = "hit_area_mc";
      
      private static const HOVER_MC:String = "hover_mc";
      
      private static const POINTS_TF:String = "points_tf";
      
      private static const QUESTTITLE_TF:String = "questtitle_tf";
      
      private var m_featureName:String;
      
      private var m_owner:GuildEventMainWindow;
      
      private const EXPANSION_TF:String = "expansion_tf";
      
      private var m_iconMc:FarmIcon;
      
      private var m_taskBt:FarmAnimatedTextButton;
      
      private var m_pointsMc:MovieClip;
      
      private var m_pointsTf:ZwTextField;
      
      private var m_countTf:ZwTextField;
      
      private var m_hover:MovieClip;
      
      public var m_slotnumber:int;
      
      private var m_task:FarmTask;
      
      private var m_data:Object;
      
      private var m_toolTip:FarmTextTooltip;
      
      private var m_isCallbackNull:Boolean = false;
      
      private var modifiedIconUrl:String;
      
      private var total:int;
      
      private var m_questTitleTf:ZwTextField;
      
      private var m_slotHitWidget:ZwFrame;
      
      private var m_playerData:Object;
      
      private var m_helpTaskIndex:int;
      
      private var m_expansionTf:ZwTextField;
      
      public function GuildEventHelpTasksSelectSlot(featureName:String, element:DisplayObject, window:GuildEventMainWindow)
      {
         this.m_featureName = featureName;
         this.m_owner = window;
         super(element);
         if(m_element.hasOwnProperty(ICON_MC))
         {
            addWidget(this.m_iconMc = new FarmIcon(m_element[ICON_MC]));
            this.m_slotHitWidget = new ZwFrame(m_element[ICON_MC]);
            this.m_slotHitWidget.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver());
            this.m_slotHitWidget.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
         }
         if(m_element.hasOwnProperty(TASK_BT))
         {
            addWidget(this.m_taskBt = new FarmAnimatedTextButton(m_element[TASK_BT],"Select",this.onClickTaskButton));
         }
         if(m_element.hasOwnProperty(POINTS_MC))
         {
            this.m_pointsMc = m_element[POINTS_MC] as MovieClip;
            if(m_element[POINTS_MC].hasOwnProperty(POINTS_TF))
            {
               this.m_pointsTf = new ZwTextField(m_element[POINTS_MC][POINTS_TF]);
            }
         }
         if(m_element.hasOwnProperty(COUNT_TF))
         {
            this.m_countTf = new ZwTextField(m_element[COUNT_TF]);
         }
         if(m_element.hasOwnProperty(this.EXPANSION_TF))
         {
            this.m_expansionTf = new ZwTextField(m_element[this.EXPANSION_TF]);
         }
         if(m_element.hasOwnProperty(HOVER_MC))
         {
            this.m_hover = m_element[HOVER_MC] as MovieClip;
            if(this.m_hover.hasOwnProperty(QUESTTITLE_TF))
            {
               this.m_questTitleTf = new ZwTextField(m_element[HOVER_MC][QUESTTITLE_TF]);
            }
         }
         if(m_element.hasOwnProperty(HIT_AREA_MC))
         {
         }
      }
      
      override public function populate(data:Object) : void
      {
         var icon:FarmIcon = null;
         var expansionText:String = null;
         super.populate(data);
         this.resetAllButtonsAndTextFeilds();
         if(Boolean(data) && data.hasOwnProperty("questTaskSlotNumber"))
         {
            this.m_slotnumber = data.questTaskSlotNumber;
         }
         this.m_data = data;
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
         }
         if(Boolean(data) && Boolean(data.hasOwnProperty("extraData")) && Boolean(data["extraData"].hasOwnProperty(GuildEventManager.PLAYER_DATA)))
         {
            this.m_playerData = data["extraData"][GuildEventManager.PLAYER_DATA];
            icon = new FarmIcon(m_element["profile_mc"] as MovieClip,this.m_playerData["pic_square"]);
            icon.setIconSize(30,30);
            icon.detachTooltip();
            icon.visible = true;
            if(this.m_playerData.hasOwnProperty("name") && this.m_playerData.name != null && this.m_data.name != "")
            {
               if(this.m_toolTip)
               {
                  this.m_toolTip.setText(this.m_playerData.name);
               }
               else
               {
                  icon.attachTooltip(this.m_toolTip = new FarmTextTooltip(this.m_playerData.name));
               }
            }
            this.m_helpTaskIndex = data["extraData"][GuildEventManager.KEY_HELP_TASK_INDEX];
         }
         if(Boolean(data) && Boolean(data.hasOwnProperty("taskType")) && data.hasOwnProperty("helperText"))
         {
         }
         this.total = int(this.m_task.total);
         this.m_countTf.text = (this.total / 2).toString();
         this.m_countTf.visible = true;
         this.m_taskBt.enabled = true;
         this.m_taskBt.visible = true;
         this.m_taskBt.callback = this.onClickTaskButton;
         this.m_isCallbackNull = false;
         this.m_pointsMc.visible = true;
         this.m_pointsTf.visible = true;
         this.m_pointsTf.text = (this.m_task.questPoints / 2).toString();
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
      }
      
      public function onClickTaskButton(event:Event) : void
      {
         this.eventManager.selectHelpTask(this.m_helpTaskIndex);
      }
      
      private function getIconUrl() : String
      {
         var result:String = "";
         return this.m_task.iconUrl;
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
      
      private function get eventManager() : GuildEventManager
      {
         return GuildEventManager.getInstance(this.m_featureName);
      }
      
      public function onMouseOver() : Function
      {
         return function(evt:MouseEvent):void
         {
            if(Boolean(m_data) && m_data.hasOwnProperty("questText"))
            {
               if(Boolean(m_hover) && Boolean(m_questTitleTf))
               {
                  m_hover.visible = true;
                  m_questTitleTf.text = getQuestTitleText(m_data.questText);
                  m_questTitleTf.visible = true;
               }
            }
         };
      }
      
      public function onMouseOut() : Function
      {
         return function(evt:MouseEvent):void
         {
            if(Boolean(m_hover) && Boolean(m_questTitleTf))
            {
               m_hover.visible = false;
               m_questTitleTf.text = "";
               m_questTitleTf.visible = false;
            }
         };
      }
      
      private function resetAllButtonsAndTextFeilds() : void
      {
         this.m_taskBt.enabled = false;
         this.m_taskBt.visible = false;
         this.m_iconMc.visible = false;
         this.m_countTf.text = "";
         this.m_countTf.visible = false;
         this.m_pointsMc.visible = false;
         this.m_pointsTf.text = "";
         this.m_pointsTf.visible = false;
         this.m_hover.visible = false;
         this.m_questTitleTf.text = "";
         this.m_questTitleTf.visible = false;
         this.m_expansionTf.text = "";
         this.m_expansionTf.visible = false;
      }
   }
}

