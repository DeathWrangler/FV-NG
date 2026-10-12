package Engine.Classes
{
   public class SocialNetworkUser
   {
      
      public var snuid:String = "0";
      
      public var snid:Number = 0;
      
      public var name:String = "";
      
      public var firstName:String = "";
      
      public var picture:String = "";
      
      public var gender:String = "";
      
      public var locale:String = "";
      
      private var userId:String;
      
      public function SocialNetworkUser(param1:String, param2:Number = 0, param3:String = "-1")
      {
         super();
         this.snuid = param1;
         this.snid = param2;
         this.userId = param3;
      }
      
      public function get uid() : String
      {
         var _loc1_:String = null;
         if(this.snid == 0)
         {
            if(this.userId != "-1")
            {
               _loc1_ = this.userId;
            }
            else
            {
               _loc1_ = this.snuid;
            }
         }
         else
         {
            _loc1_ = this.snid.toString() + ":" + this.snuid;
         }
         return _loc1_;
      }
   }
}

