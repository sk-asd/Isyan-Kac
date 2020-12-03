#include <sourcemod>
#include <warden>
#include <sdktools>
#include <cstrike>
#pragma semicolon 1
#pragma newdecls required
int Isyan = 0, kazanan = 0;
ConVar issinir = null, isbildirim = null;
public Plugin myinfo =  { author = "phiso", name = "İsyan kaç???", version = "1.1" };
public void OnMapStart()
{
	char mapismi[512];
	GetCurrentMap(mapismi, sizeof(mapismi));
	if (StrContains(mapismi, "jb_", false) != 0 && StrContains(mapismi, "jail_", false) != 0 && StrContains(mapismi, "ba_jail", false) != 0)
	{
		SetFailState("[İsyan Kaç] Bu Plugin sadece Jailbreak modunda çalışabilir.");
	}
}
public void OnPluginStart()
{
	isbildirim = CreateConVar("sm_iskac_isyanbildir", "2", "İsyan eli için isyan sayısı.");
	issinir = CreateConVar("sm_iskac_issinir", "3", "İsyan Kaç Olduğunda komutçuya koruma atılsın mı menüsü gelsin?");
	
	AutoExecConfig(true, "Isyan-Kac", "phiso");
	
	RegConsoleCmd("sm_isyankac", IsyanKac);
	RegConsoleCmd("sm_iskac", IsyanKac);
	RegAdminCmd("sm_isyansifirla", IsyanSifirla, ADMFLAG_SLAY);
	
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("round_start", Event_RoundStart);
	
}
public Action IsyanSifirla(int client, int args)
{
	PrintToChatAll("[SM] \x02%N \x0Ftarafından \x04isyan sıfırlandı.", client);
	PrintToChat(client, "[SM] \x02İsyan \x04sıfırlandı.");
	Isyan = 0;
}
public Action IsyanKac(int client, int args)
{
	PrintToChatAll("[SM] \x05İsyan sayısı: \x0F%d", Isyan);
}
public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	kazanan = event.GetInt("winner");
	if (kazanan > 1)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (GetClientTeam(i) != kazanan && GetClientTeam(i) == CS_TEAM_CT && warden_iswarden(i))
			{
				MenuGoster(i);
			}
		}
	}
	kazanan = 0;
}
public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	PrintToChatAll("Şuanki isyan sayısı: %d", Isyan);
	if (Isyan == isbildirim.IntValue)
	{
		PrintToChatAll("[SM] \x05Eğer \x02isyan eli \x07yapmadıysanız \x02bu el isyan eli!");
	}
	else
	{
		if (Isyan == issinir.IntValue)
		{
			Isyan = 0;
			for (int i = 1; i < MaxClients; i++)
			{
				if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_CT && !IsFakeClient(i) && warden_iswarden(i))
				{
					KorumaAtilsinMi(i);
				}
			}
		}
	}
}
public Action MenuGoster(int client)
{
	if (warden_iswarden(client))
	{
		Menu menu = new Menu(Isyan_Menu, MenuAction_Select | MenuAction_End);
		menu.SetTitle("Bu el isyan sayılsın mı?\n");
		menu.AddItem("yes", "Evet, İsyan sayılsın.");
		menu.AddItem("no", "Hayır, İsyan sayılmasın.");
		menu.ExitBackButton = false;
		menu.Display(client, MENU_TIME_FOREVER);
	}
}
public Action KorumaAtilsinMi(int client)
{
	if (warden_iswarden(client))
	{
		Menu menu = new Menu(KorumaAtilsinCevap, MenuAction_Select | MenuAction_End);
		menu.SetTitle("Koruma Atılsın Mı?");
		menu.AddItem("evet", "Evet, Seçtiğim Koruma Atılsın.");
		menu.AddItem("hayir", "Hayır, Herhangi bir koruma atılmasın.");
		menu.ExitBackButton = false;
		menu.Display(client, MENU_TIME_FOREVER);
	}
}
public Action KorumaAtilsin(int client)
{
	Menu menu = new Menu(Koruma_Handler);
	menu.SetTitle("Atılacak korumayı seçin!");
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_CT && !IsFakeClient(i) && !warden_iswarden(i) && i != client)
		{
			char liste[32], name[MAX_NAME_LENGTH];
			GetClientName(i, name, sizeof(name));
			Format(liste, sizeof(liste), "%i", i);
			menu.AddItem(liste, name);
		}
	}
	menu.Display(client, MENU_TIME_FOREVER);
}
public int KorumaAtilsinCevap(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char Item[32];
		menu.GetItem(param2, Item, sizeof(Item));
		if (warden_iswarden(param1))
		{
			if (strcmp(Item, "evet") == 0)
			{
				KorumaAtilsin(param1);
			}
			if (strcmp(Item, "hayır") == 0)
			{
				delete menu;
				PrintToChatAll("[SM] \x0BKomutçu \x05Korumaların \x02atılmamasını \x05tercih etti!");
			}
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}
public int Koruma_Handler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[32], name[64];
		int target;
		menu.GetItem(param2, info, sizeof(info));
		target = StringToInt(info);
		GetClientName(target, name, sizeof(name));
		if (target != 0)
		{
			CS_SwitchTeam(target, CS_TEAM_T);
			PrintToChatAll("[SM] \x02%s \x05isimli koruma \x02kovuldu!", name);
			delete menu;
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}
public int Isyan_Menu(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char Item[32];
		menu.GetItem(param2, Item, sizeof(Item));
		if (warden_iswarden(param1))
		{
			if (strcmp(Item, "yes") == 0)
			{
				Isyan++;
				PrintToChatAll("[SM] \x05Isyan sayısına \x02+1 \x05eklendi!");
				PrintToChatAll("[SM] \x05Şuanki isyan sayısı: \x02%d", Isyan);
				delete menu;
			}
			if (strcmp(Item, "no") == 0)
			{
				delete menu;
				PrintToChatAll("[SM] \x05Bu el isyan olmadığı için isyan puanı eklenmedi!");
			}
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
} 