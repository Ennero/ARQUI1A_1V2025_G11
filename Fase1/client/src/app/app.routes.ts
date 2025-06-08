import { Routes } from '@angular/router';
import { Login } from './login/login';
import { Dashboard } from './dashboard/dashboard';
import { History } from './history/history';
import { Exit } from './exit/exit';

export const routes: Routes = [
    {path: 'login', component: Login},
    {path: 'dashboard', component: Dashboard},
    {path: 'history', component: History},
    {path: 'exit', component: Exit},
    {path: '', redirectTo: 'login', pathMatch: 'full'}
];
