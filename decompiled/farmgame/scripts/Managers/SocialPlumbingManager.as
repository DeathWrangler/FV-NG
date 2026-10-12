package Managers
{
   import Classes.SocialPlumbing.SocialPlumbingAction;
   import Classes.util.ZLocUtils;
   import Display.QueuedIcon;
   import Engine.Managers.TransactionManager;
   import Transactions.TCompleteSocialPlumbingAction;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class SocialPlumbingManager
   {
      
      private static var m_allowInstantiation:Boolean;
      
      public static const MAIN_STATS_COUNTER:String = "social_plumbing_to_do_list";
      
      public static const EXPERIMENT_SP_TODO_LIST:String = "fv_sp_to_do_list";
      
      private static var m_instance:SocialPlumbingManager = null;
      
      protected static const HUD_ICON_NAME:String = "SocialPlumbingTodoList";
      
      private var m_socialTaskList:Array = null;
      
      private var m_rawSocialActions:Array = null;
      
      private var m_spQueuedIcon:QueuedIcon = null;
      
      protected var m_friendDataLoaded:Boolean = false;
      
      public function SocialPlumbingManager()
      {
         super();
         if(!m_allowInstantiation)
         {
            throw new Error("Error: Instantiation failed: Use SocialPlumbingManager.getInstance() instead of new.");
         }
      }
      
      public static function getInstance() : SocialPlumbingManager
      {
         if(m_instance == null)
         {
            m_allowInstantiation = true;
            m_instance = new SocialPlumbingManager();
            m_allowInstantiation = false;
         }
         return m_instance;
      }
      
      public function get friendDataLoaded() : Boolean
      {
         return this.m_friendDataLoaded;
      }
      
      public function set friendDataLoaded(value:Boolean) : void
      {
         this.m_friendDataLoaded = value;
      }
      
      public function setRawSocialActions(rawSocialActions:Array) : void
      {
         this.m_rawSocialActions = rawSocialActions;
         this.getTaskList();
      }
      
      public function hasCompletedAllActions() : Boolean
      {
         var socialAction:SocialPlumbingAction = null;
         var result:Boolean = true;
         for each(socialAction in this.m_socialTaskList)
         {
            if(Boolean(socialAction) && !socialAction.isComplete)
            {
               result = false;
               break;
            }
         }
         return result;
      }
      
      public function getAction(className:String, targetFriendId:String) : SocialPlumbingAction
      {
         var socialAction:SocialPlumbingAction = null;
         var currentClassName:String = null;
         var result:SocialPlumbingAction = null;
         for each(socialAction in this.m_socialTaskList)
         {
            currentClassName = SocialPlumbingAction.getServerClassNameFromAction(socialAction);
            if(Boolean(socialAction) && Boolean(socialAction.friendUid == targetFriendId) && className == currentClassName)
            {
               result = socialAction;
               break;
            }
         }
         return result;
      }
      
      public function logDisplayedList() : void
      {
         var socialAction:SocialPlumbingAction = null;
         var className:String = null;
         var result:Boolean = true;
         for each(socialAction in this.m_socialTaskList)
         {
            if(socialAction)
            {
               className = SocialPlumbingAction.getServerClassNameFromAction(socialAction);
               FarmStatsManager.count(SocialPlumbingManager.MAIN_STATS_COUNTER,"social_actions_displayed",className);
            }
         }
      }
      
      public function getNumIncompleteActions() : int
      {
         var socialAction:SocialPlumbingAction = null;
         var result:Number = 0;
         for each(socialAction in this.m_socialTaskList)
         {
            if(Boolean(socialAction) && !socialAction.isComplete)
            {
               result++;
            }
         }
         return result;
      }
      
      public function getTaskList() : Array
      {
         var rawSocialAction:Object = null;
         var className:String = null;
         var data:Object = null;
         var isComplete:Boolean = false;
         var socialPlumbingActionClass:Class = null;
         var socialPlumbingAction:SocialPlumbingAction = null;
         if(this.m_socialTaskList == null && this.m_rawSocialActions != null && this.m_friendDataLoaded)
         {
            this.m_socialTaskList = new Array();
            for each(rawSocialAction in this.m_rawSocialActions)
            {
               className = rawSocialAction["className"];
               data = rawSocialAction["data"];
               isComplete = Boolean(rawSocialAction["isComplete"]);
               if(Boolean(className && data != null) && Boolean(data["uid"] != null) && Global.friendManager.getFriendData(data["uid"]) != null)
               {
                  socialPlumbingActionClass = SocialPlumbingAction.getActionFromServerClassName(className);
                  socialPlumbingAction = new socialPlumbingActionClass(data);
                  socialPlumbingAction.isComplete = isComplete;
                  this.m_socialTaskList.push(socialPlumbingAction);
               }
            }
            this.addHUDIcon();
         }
         return this.m_socialTaskList;
      }
      
      public function updateCompletedTask(className:String, targetFriendId:String, postedFeed:Boolean = false) : Boolean
      {
         var result:Boolean = false;
         var spAction:SocialPlumbingAction = this.getAction(className,targetFriendId);
         if(spAction)
         {
            Global.player.incrementActionCount(SocialPlumbingAction.NUM_FRIENDS_HELPED_KEY,false);
            TransactionManager.addTransaction(new TCompleteSocialPlumbingAction(className,targetFriendId),true);
            if(postedFeed)
            {
               FarmStatsManager.count(SocialPlumbingManager.MAIN_STATS_COUNTER,"social_actions_completed",className);
            }
            spAction.isComplete = true;
            result = true;
            this.updateHUDIcon();
         }
         return result;
      }
      
      private function addHUDIcon() : void
      {
         var numIncompleteActions:Number = this.getNumIncompleteActions();
         if(Boolean(this.m_socialTaskList) && Boolean(numIncompleteActions > 0) && !this.m_spQueuedIcon)
         {
            this.m_spQueuedIcon = Global.hud.iconQueue.addIconToTop(HUD_ICON_NAME);
            this.updateHUDIcon();
            FarmStatsManager.count(SocialPlumbingManager.MAIN_STATS_COUNTER,"icon_impressions");
         }
      }
      
      public function updateHUDIcon() : void
      {
         var numIncompleteActions:Number = NaN;
         var iconFiller:Function = null;
         var iconContent:DisplayObject = null;
         var iconMc:MovieClip = null;
         numIncompleteActions = this.getNumIncompleteActions();
         if(Boolean(this.m_spQueuedIcon) && numIncompleteActions > 0)
         {
            iconFiller = function(content:DisplayObject):void
            {
               var mc:MovieClip = content as MovieClip;
               if(mc)
               {
                  if(mc.friendNumber_tf)
                  {
                     mc.friendNumber_tf.text = numIncompleteActions.toString();
                  }
               }
            };
            iconContent = this.m_spQueuedIcon.getContent();
            this.m_spQueuedIcon.contentManip = iconFiller;
            if(iconContent)
            {
               iconMc = iconContent as MovieClip;
               iconMc.friendNumber_tf.text = numIncompleteActions;
            }
            this.m_spQueuedIcon.toolTip = ZLocUtils.t("Dialogs","SocialPlumbingHUD_iconTooltip",{"quantity":numIncompleteActions});
            Global.hud.markDirty();
         }
         else if(Boolean(this.m_spQueuedIcon) && numIncompleteActions <= 0)
         {
            Global.hud.iconQueue.removeIconByName(HUD_ICON_NAME);
            Global.hud.markDirty();
         }
      }
   }
}

