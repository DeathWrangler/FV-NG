package Managers
{
   import Classes.SocialAction;
   import Display.HUD.MessageCenterButton;
   import Engine.Managers.TransactionManager;
   import Transactions.TMarkSeenSocialActions;
   
   public class SocialActionsManager
   {
      
      private static var m_instance:SocialActionsManager = null;
      
      private static var m_canInstantiate:Boolean = false;
      
      private var m_actions:Array = new Array();
      
      public function SocialActionsManager()
      {
         super();
         if(!m_canInstantiate)
         {
            throw new Error("Cannot call SocialActionsManager constructor directly - use getInstance() instead.");
         }
      }
      
      public static function getInstance() : SocialActionsManager
      {
         if(null == m_instance)
         {
            m_canInstantiate = true;
            m_instance = new SocialActionsManager();
            m_canInstantiate = false;
         }
         return m_instance;
      }
      
      public static function sortByTime(action1:SocialAction, action2:SocialAction) : int
      {
         var result:int = 0;
         var action1Time:Number = action1.getTimestamp();
         var action2Time:Number = action2.getTimestamp();
         if(action1Time > action2Time)
         {
            result = -1;
         }
         else if(action2Time > action1Time)
         {
            result = 1;
         }
         else
         {
            result = 0;
         }
         return result;
      }
      
      public function loadObject(data:Object) : void
      {
         var actionIdx:int = 0;
         var actionData:Object = null;
         this.m_actions = [];
         if(data)
         {
            for(actionIdx = 0; actionIdx < data.length; actionIdx++)
            {
               actionData = data[actionIdx];
               this.m_actions.push(new SocialAction(actionData.id,actionData.action,actionData.friend,actionData.timestamp,actionData.isNew,actionData.itemCode));
            }
         }
         var messageCenterButton:MessageCenterButton = Global.hud.messageCenterButton;
         if(messageCenterButton)
         {
            messageCenterButton.setUpNotificationBubble();
         }
      }
      
      public function getActions() : Array
      {
         this.m_actions.sort(sortByTime);
         return this.m_actions;
      }
      
      public function markNewActionsAsSeen() : void
      {
         var action:SocialAction = null;
         var actionIds:Array = new Array();
         for each(action in this.m_actions)
         {
            if(action.isNew())
            {
               actionIds.push(action.getId());
               action.setSeen();
            }
         }
         if(!Global.worldManager.isVisiting() && actionIds.length > 0)
         {
            TransactionManager.addTransaction(new TMarkSeenSocialActions(actionIds));
         }
      }
      
      public function getNumNewActions() : int
      {
         var action:SocialAction = null;
         var count:int = 0;
         for each(action in this.m_actions)
         {
            if(action.isNew())
            {
               count++;
            }
         }
         return count;
      }
   }
}

