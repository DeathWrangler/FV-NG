package Engine.Transactions
{
   public class TSendNotification extends Transaction
   {
      
      protected var m_targetUserIds:Array = [];
      
      protected var m_params:Array = [];
      
      protected var m_action:String;
      
      public function TSendNotification(param1:String, param2:Array, param3:Array)
      {
         super();
         this.m_action = param1;
         this.m_params = param2.concat();
         this.m_targetUserIds = param3.concat();
      }
      
      override public function perform() : void
      {
         var _loc2_:int = 0;
         var _loc1_:Array = new Array();
         if(this.m_targetUserIds)
         {
            _loc2_ = 0;
            while(_loc2_ < this.m_targetUserIds.length)
            {
               _loc1_.push(this.m_targetUserIds[_loc2_].toString());
               _loc2_++;
            }
         }
         signedCall("UserService.sendUserNotification",this.m_action,this.m_params,_loc1_);
      }
   }
}

