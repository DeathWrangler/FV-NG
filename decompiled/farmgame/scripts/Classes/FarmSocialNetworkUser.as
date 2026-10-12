package Classes
{
   import Engine.Classes.SocialNetworkUser;
   
   public class FarmSocialNetworkUser extends SocialNetworkUser
   {
      
      public function FarmSocialNetworkUser(uid:String)
      {
         super(uid);
      }
      
      override public function get uid() : String
      {
         return this.snuid;
      }
   }
}

