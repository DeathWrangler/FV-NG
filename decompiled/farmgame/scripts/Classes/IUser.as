package Classes
{
   import Classes.Avatar.FarmAvatar;
   import Engine.Classes.SocialNetworkUser;
   
   public interface IUser
   {
      
      function get snUser() : SocialNetworkUser;
      
      function set snUser(param1:SocialNetworkUser) : void;
      
      function get name() : String;
      
      function get firstName() : String;
      
      function get uid() : String;
      
      function get xp() : Number;
      
      function get worldScores() : Object;
      
      function get currentWorldScore() : Number;
      
      function get currentWorldScore2() : Number;
      
      function get currentWorldLevel() : Number;
      
      function get currentWorldLevel2() : Number;
      
      function get level() : Number;
      
      function get avatar() : FarmAvatar;
      
      function set avatar(param1:FarmAvatar) : void;
      
      function get avatarData() : Object;
      
      function set avatarData(param1:Object) : void;
      
      function get picture() : String;
      
      function get cardStats() : Object;
      
      function get fake() : Boolean;
      
      function get empty() : Boolean;
      
      function get usedPhotoContest() : Boolean;
      
      function getFeatureCreditsReceived(param1:String, param2:Boolean = false) : int;
      
      function getBreedingStatsByFeatureName(param1:String) : int;
   }
}

