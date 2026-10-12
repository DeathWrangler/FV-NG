package ZQuest.Classes
{
   public class Quest
   {
      
      protected var m_xml:XML = null;
      
      protected var m_name:String;
      
      protected var m_icon:String;
      
      protected var m_feed:String;
      
      protected var m_delay:int;
      
      protected var m_popupDelay:int;
      
      protected var m_visible:Boolean;
      
      protected var m_tasks:Vector.<Object>;
      
      protected var m_rewards:Vector.<String>;
      
      public function Quest(param1:XML)
      {
         var _loc4_:Object = null;
         this.m_tasks = new Vector.<Object>();
         this.m_rewards = new Vector.<String>();
         super();
         this.m_xml = param1;
         this.m_name = String(param1.@name);
         this.m_icon = String(param1.@url);
         this.m_feed = String(param1.@feed);
         this.m_delay = int(param1.@delay);
         this.m_popupDelay = int(param1.@popup_delay);
         this.m_visible = String(param1.@visible) == "true";
         var _loc2_:int = 0;
         while(_loc2_ < this.m_xml.tasks.task.length())
         {
            param1 = this.m_xml.tasks.task[_loc2_];
            _loc4_ = new Object();
            _loc4_.action = String(param1.@action);
            _loc4_.type = String(param1.@type);
            _loc4_.total = int(param1.@total);
            _loc4_.cost = int(param1.@cost);
            _loc4_.filter = String(param1.@filter);
            _loc4_.sticky = String(param1.@sticky) == "true";
            _loc4_.percent = String(param1.@percent) == "true";
            _loc4_.icon = String(param1.@icon_url);
            this.m_tasks.push(_loc4_);
            _loc2_++;
         }
         var _loc3_:int = 0;
         while(_loc3_ < this.m_xml.rewards.reward.length())
         {
            this.m_rewards.push(String(this.m_xml.rewards.reward[_loc3_].@url));
            _loc3_++;
         }
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get icon() : String
      {
         return this.m_icon;
      }
      
      public function get feed() : String
      {
         return this.m_feed;
      }
      
      public function get delay() : int
      {
         return this.m_delay;
      }
      
      public function get popupDelay() : int
      {
         return this.m_popupDelay;
      }
      
      public function get visible() : Boolean
      {
         return this.m_visible;
      }
      
      public function get tasks() : Vector.<Object>
      {
         return this.m_tasks;
      }
      
      public function get rewards() : Vector.<String>
      {
         return this.m_rewards;
      }
   }
}

